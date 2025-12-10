import Foundation

protocol ProfileViewModelDelegate: AnyObject {
    func profileViewModelDidUpdateState(_ viewModel: ProfileViewModel)
    func profileViewModel(_ viewModel: ProfileViewModel, didEncounterError error: Error)
    func profileViewModelDidReachEnd(_ viewModel: ProfileViewModel)
}

class ProfileViewModel {
    
    weak var delegate: ProfileViewModelDelegate?
    
    private var profiles: [Profile] = []
    private var currentProfileIndex: Int = 0
    private var configuration: ProfileConfiguration?
    private let networkService: ProfileConfigurationFetcher
    
    var currentProfile: Profile? {
        guard currentProfileIndex < profiles.count else { return nil }
        return profiles[currentProfileIndex]
    }
    
    var fieldOrder: [String] {
        return configuration?.fieldOrder ?? defaultFieldOrder()
    }
    
    var orderedFieldNames: [String] {
        guard let profile = currentProfile else { return [] }
        
        return fieldOrder.filter { fieldName in
            shouldDisplayField(fieldName, in: profile)
        }
    }
    
    private func shouldDisplayField(_ fieldName: String, in profile: Profile) -> Bool {
        switch fieldName {
        case "photo":
            return profile.photo != nil
        case "about_me", "about":
            return profile.about != nil
        case "name", "gender":
            return true
        case "age":
            return profile.age != nil
        case "school":
            return profile.school != nil
        case "job":
            return profile.job != nil
        case "location":
            return profile.location != nil
        default:
            return false
        }
    }
    
    var canNavigateToNext: Bool {
        return currentProfileIndex < profiles.count - 1
    }
    
    var nextButtonTitle: String {
        return canNavigateToNext ? "Next Profile" : "No More Profiles"
    }
    
    var isLoading: Bool = false {
        didSet {
            delegate?.profileViewModelDidUpdateState(self)
        }
    }
    
    init(networkService: ProfileConfigurationFetcher = ProfileConfigurationFetcher.shared) {
        self.networkService = networkService
    }
    
    func loadProfiles() {
        isLoading = true
        
        let group = DispatchGroup()
        var loadedProfiles: [Profile] = []
        var loadedConfiguration: ProfileConfiguration?
        var loadError: Error?
        
        group.enter()
        networkService.fetchProfiles { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let profiles):
                loadedProfiles = profiles
            case .failure(let error):
                loadError = error
                print("Error loading profiles: \(error)")
            }
        }
        
        group.enter()
        networkService.fetchProfileConfiguration { result in
            defer { group.leave() }
            switch result {
            case .success(let config):
                loadedConfiguration = config
            case .failure(let error):
                if loadError == nil {
                    loadError = error
                }
                print("Error loading configuration: \(error)")
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = loadError {
                self.delegate?.profileViewModel(self, didEncounterError: error)
                return
            }
            
            self.profiles = loadedProfiles
            self.configuration = loadedConfiguration
            
            if self.profiles.isEmpty {
                self.delegate?.profileViewModelDidUpdateState(self)
            } else {
                self.delegate?.profileViewModelDidUpdateState(self)
            }
        }
    }
    
    func moveToNextProfile() {
        guard canNavigateToNext else {
            delegate?.profileViewModelDidReachEnd(self)
            return
        }
        
        currentProfileIndex += 1
        delegate?.profileViewModelDidUpdateState(self)
    }
    
    func resetToFirstProfile() {
        currentProfileIndex = 0
        delegate?.profileViewModelDidUpdateState(self)
    }
    
    private func defaultFieldOrder() -> [String] {
        return ["photo", "name", "age", "about_me", "school", "job", "location"]
    }
}

