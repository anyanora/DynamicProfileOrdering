import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
}

class ProfileConfigurationFetcher {
    static let shared = ProfileConfigurationFetcher()
    
    private let baseURL = "http://hinge-ue1-dev-cli-android-homework.s3-website-us-east-1.amazonaws.com"
    
    private init() {}
    
    func fetchProfiles(completion: @escaping (Result<[Profile], NetworkError>) -> Void) {
        guard let url = URL(string: baseURL)?.appendingPathComponent("users") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let wrapped = try JSONDecoder().decode(ProfilesResponse.self, from: data)
                completion(.success(wrapped.users))
            } catch {
                do {
                    let users = try JSONDecoder().decode([Profile].self, from: data)
                    completion(.success(users))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        
    }
    
    func fetchProfileConfiguration(completion: @escaping (Result<ProfileConfiguration, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL)?.appendingPathComponent("config") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ProfileConfigurationResponse.self, from: data)
                completion(.success(response.configuration))
            } catch {
                struct ProfileArrayWrapper: Codable { let profile: [String] }
                if let wrapper = try? JSONDecoder().decode(ProfileArrayWrapper.self, from: data) {
                    completion(.success(ProfileConfiguration(fieldOrder: wrapper.profile)))
                    return
                }
                if let array = try? JSONDecoder().decode([String].self, from: data) {
                    completion(.success(ProfileConfiguration(fieldOrder: array)))
                    return
                }
                if let config = try? JSONDecoder().decode(ProfileConfiguration.self, from: data) {
                    completion(.success(config))
                    return
                }
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

