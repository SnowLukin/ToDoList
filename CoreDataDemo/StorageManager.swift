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
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    private init() {}
}

extension StorageManager {
    
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
    
    func createTask(_ taskName: String) {
        let task = Task(context: context)
        task.name = taskName
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
