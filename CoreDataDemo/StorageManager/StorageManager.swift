//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by  BoDim on 29.01.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private let context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let task = try context.fetch(fetchRequest)
            completion(.success(task))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func save(_ taskName: String, completion: @escaping (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func edit(_ task: Task, newName: String) {
        task.title = newName
        saveContext()
    }
    
    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
}
