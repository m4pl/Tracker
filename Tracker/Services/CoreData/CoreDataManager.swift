//
//  CoreDataManager.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import Foundation
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        let container = NSPersistentContainer(name: "TrackerModel")

        let trackerStoreURL = CoreDataManager.getStoreURL(for: "Tracker.sqlite")
        let categoryStoreURL = CoreDataManager.getStoreURL(for: "Category.sqlite")
        let recordStoreURL = CoreDataManager.getStoreURL(for: "Record.sqlite")

        let trackerStore = NSPersistentStoreDescription(url: trackerStoreURL)
        let categoryStore = NSPersistentStoreDescription(url: categoryStoreURL)
        let recordStore = NSPersistentStoreDescription(url: recordStoreURL)

        container.persistentStoreDescriptions = [trackerStore, categoryStore, recordStore]

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading storage: \(error)")
            }
        }

        self.persistentContainer = container
    }

    private static func getStoreURL(for fileName: String) -> URL {
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return storeURL.appendingPathComponent(fileName)
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
    }
}
