//
//  CoreDataManager.swift
//  CoreDemoApp
//
//  Created by Dinmukhammed Sagyntkan on 19.04.2022.
//

import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    lazy var viewContext = persistentContainer.viewContext

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDemoApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {}

    func fetchData() -> [Task] {
        var tasks: [Task] = []
        let fetchRequest = Task.fetchRequest()
        do {
            tasks = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return tasks
    }

    func saveTask(_ taskName: String) -> Task {
        let task = Task(context: viewContext)
        task.title = taskName
        trySaveViewContext(viewContext)

        return task
    }

    func editTask(currentTask: Task, _ newTaskTitle: String) {
        currentTask.title = newTaskTitle
        trySaveViewContext(viewContext)
    }

    func deleteTask(currentTask: Task) {
        viewContext.delete(currentTask)
        trySaveViewContext(viewContext)
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private func trySaveViewContext(_ viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
