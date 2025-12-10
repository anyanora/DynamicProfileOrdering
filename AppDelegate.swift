import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create ViewModel with dependency injection
        let viewModel = ProfileViewModel(networkService: ProfileConfigurationFetcher.shared)
        let dynamicProfileViewController = DynamicProfileViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: dynamicProfileViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

