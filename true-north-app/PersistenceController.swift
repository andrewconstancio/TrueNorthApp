import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container = NSPersistentContainer(name: "GoalDataContainer")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
}
