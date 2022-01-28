//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Snow Lukin on 26.01.2022.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
}

// MARK: Public Methods
extension StorageManager {
    
    func fetchData(completion: (Result<[Task], Error>) -> Void)  {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(.success(tasks))
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createTask(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.name = taskName
        completion(task)
        saveContext()
    }
    
    func deleteTask(task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func editTask(task: Task, _ newName: String) {
        task.name = newName
        saveContext()
    }
    
}
