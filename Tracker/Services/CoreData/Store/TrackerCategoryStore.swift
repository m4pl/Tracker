//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import Foundation
import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error during FRC initialization: \(error)")
        }
    }
    
    func getCategories() throws -> [TrackerCategory] {
        guard let categories = fetchedResultsController.fetchedObjects else { return [] }
        
        return categories.compactMap { category in
            if let title = category.title,
               let trackers = category.trackers as? Set<TrackerCoreData> {
                
                let models = trackers.compactMap { tracker -> Tracker? in
                    guard let id = tracker.id,
                          let name = tracker.name,
                          let emoji = tracker.emoji,
                          let colorHex = tracker.colorHex,
                          let schedule = tracker.schedule as? [Int]
                    else { return nil }
                    
                    return Tracker(
                        id: id,
                        name: name,
                        color: UIColor(hex: colorHex),
                        emoji: emoji,
                        schedule: schedule.compactMap { WeekDay(rawValue: $0) }
                    )
                }
                
                return TrackerCategory(title: title, trackers: models)
            } else {
                return nil
            }
        }
    }
    func add(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)

        let existingCategories = try context.fetch(request)
        let categoryEntity: TrackerCategoryCoreData

        if let existing = existingCategories.first {
            categoryEntity = existing
        } else {
            categoryEntity = TrackerCategoryCoreData(context: context)
            categoryEntity.title = category.title
        }

        let existingTrackers = (categoryEntity.trackers as? Set<TrackerCoreData>) ?? []
        let existingTrackerIDs = Set(existingTrackers.map { $0.id })
        let newTrackers = category.trackers.filter { !existingTrackerIDs.contains($0.id) }
        let newTrackerEntities = newTrackers.map { tracker -> TrackerCoreData in
            let trackerEntity = TrackerCoreData(context: context)
            trackerEntity.id = tracker.id
            trackerEntity.name = tracker.name
            trackerEntity.emoji = tracker.emoji
            trackerEntity.colorHex = tracker.color.toHex()
            trackerEntity.schedule = tracker.schedule.map { $0.rawValue } as NSArray
            trackerEntity.category = categoryEntity
            return trackerEntity
        }

        let updatedTrackers = existingTrackers.union(newTrackerEntities)
        categoryEntity.trackers = NSSet(set: updatedTrackers)

        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange(self)
    }
}
