//
//  CoreDataManager.swift
//  CoreDemoApp
//
//  Created by Dinmukhammed Sagyntkan on 19.04.2022.
//

import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDemoApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {}

    func fetchData(completion: @escaping(Result<[Task], Error>) -> Void) {
        var tasks: [Task] = []
        let fetchRequest = Task.fetchRequest()
        do {
            tasks = try viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }

    func saveTask(_ taskName: String, completion: @escaping(Result<Task, Error>) -> Void) {
        let task = Task(context: viewContext)
        task.title = taskName
        completion(.success(task))
        saveContext()
    }

    func editTask(currentTask: Task, _ newTaskTitle: String) {
        currentTask.title = newTaskTitle
        saveContext()
    }

    func deleteTask(currentTask: Task) {
        viewContext.delete(currentTask)
        saveContext()
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
}
