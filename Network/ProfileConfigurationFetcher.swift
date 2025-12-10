import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
}

class ProfileConfigurationFetcher {
    static let shared = ProfileConfigurationFetcher()
    
    private let baseURL = "http://hinge-ue1-dev-cli-android-homework.s3-website-us-east-1.amazonaws.com/"
    
    private init() {}
    
    func fetchProfiles(completion: @escaping (Result<[Profile], NetworkError>) -> Void) {
        let url = URL(string: "\(baseURL)/users")!
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
                let response = try JSONDecoder().decode(ProfilesResponse.self, from: data)
                completion(.success(response.users))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
    
    func fetchProfileConfiguration(completion: @escaping (Result<ProfileConfiguration, NetworkError>) -> Void) {
        let url = URL(string: "\(baseURL)/config")!
        URLSession.shared.dataTask(with: url) { data, _, error in
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
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

