import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
       _ application: UIApplication,
       configurationForConnecting connectingSceneSession: UISceneSession,
       options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
       let sceneConfiguration = UISceneConfiguration(
           name: "Main",
           sessionRole: connectingSceneSession.role
       )
       sceneConfiguration.delegateClass = SceneDelegate.self 
       return sceneConfiguration
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerData")
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

}
