import Foundation

enum ProfileFieldType: String {
    case photo
    case aboutMe = "about_me"
    case name
    case age
    case school
    case job
    case location
    case gender
}

struct ProfileFieldViewModel {
    let type: ProfileFieldType
    let title: String
    let value: String?
    let photos: [String]?
    
    init(type: ProfileFieldType, profile: Profile) {
        self.type = type
        
        switch type {
        case .photo:
            self.title = ""
            self.value = nil
            self.photos = profile.photo != nil ? [profile.photo!] : nil
        case .aboutMe:
            self.title = "About Me"
            self.value = profile.about
            self.photos = nil
        case .name:
            self.title = "Name"
            self.value = profile.name
            self.photos = nil
        case .age:
            self.title = "Age"
            self.value = profile.age != nil ? "\(profile.age!)" : nil
            self.photos = nil
        case .gender:
            self.title = "Gender"
            self.value = profile.gender
            self.photos = nil
        case .school:
            self.title = "School"
            self.value = profile.school
            self.photos = nil
        case .job:
            self.title = "Job"
            self.value = profile.job
            self.photos = nil
        case .location:
            self.title = "Location"
            self.value = profile.location
            self.photos = nil
        }
    }
    
    var shouldDisplay: Bool {
        switch type {
        case .photo:
            return !(photos?.isEmpty ?? true)
        case .aboutMe, .school, .job, .location, .age:
            return value != nil
        case .name, .gender:
            return true
        }
    }
}

