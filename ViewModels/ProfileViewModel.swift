//
//  ProfileViewModel.swift
//  DynamicProfileOrdering
//
//  Created on $(date)
//

import Foundation

protocol ProfileViewModelDelegate: AnyObject {
    func profileViewModelDidUpdateState(_ viewModel: ProfileViewModel)
    func profileViewModel(_ viewModel: ProfileViewModel, didEncounterError error: Error)
    func profileViewModelDidReachEnd(_ viewModel: ProfileViewModel)
}

class ProfileViewModel {
    
    // MARK: - Properties
    weak var delegate: ProfileViewModelDelegate?
    
    private var profiles: [Profile] = []
    private var currentProfileIndex: Int = 0
    private var configuration: ProfileConfiguration?
    private let networkService: ProfileConfigurationFetcher
    
    // MARK: - Computed Properties
    var currentProfile: Profile? {
        guard currentProfileIndex < profiles.count else { return nil }
        return profiles[currentProfileIndex]
    }
    
    var fieldOrder: [String] {
        return configuration?.fieldOrder ?? defaultFieldOrder()
    }
    
    var orderedFields: [ProfileFieldViewModel] {
        guard let profile = currentProfile else { return [] }
        
        return fieldOrder.compactMap { fieldName in
            guard let fieldType = ProfileFieldType(rawValue: fieldName) else { return nil }
            let fieldViewModel = ProfileFieldViewModel(type: fieldType, profile: profile)
            return fieldViewModel.shouldDisplay ? fieldViewModel : nil
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
    
    // MARK: - Initialization
    init(networkService: ProfileConfigurationFetcher = ProfileConfigurationFetcher.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    func loadProfiles() {
        isLoading = true
        
        let group = DispatchGroup()
        var loadedProfiles: [Profile] = []
        var loadedConfiguration: ProfileConfiguration?
        var loadError: Error?
        
        // Load profiles
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
        
        // Load configuration
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
                // Handle empty state
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
    
    // MARK: - Private Methods
    private func defaultFieldOrder() -> [String] {
        return ["photo", "name", "age", "about_me", "school", "job", "location"]
    }
}

