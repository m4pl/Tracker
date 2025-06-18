//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import Foundation
import CoreData

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
        
        let sortedCategories = categories.sorted { ($0.title ?? "") < ($1.title ?? "") }
        
        return sortedCategories.compactMap { category in
            guard let title = category.title,
                  let trackersSet = category.trackers as? Set<TrackerCoreData> else {
                return nil
            }
            
            let sortedTrackers = trackersSet
                .compactMap { tracker -> Tracker? in
                    guard let id = tracker.id,
                          let name = tracker.name,
                          let emoji = tracker.emoji,
                          let colorHex = tracker.colorHex,
                          let schedule = tracker.schedule as? [Int]
                    else { return nil }
                    
                    return Tracker(
                        id: id,
                        name: name,
                        color: colorHex,
                        emoji: emoji,
                        schedule: schedule.compactMap { WeekDay(rawValue: $0) }
                    )
                }
                .sorted { $0.name < $1.name }
            
            return TrackerCategory(title: title, trackers: sortedTrackers)
        }
    }
    
    func create(_ name: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", name)
        
        do {
            let existing = try context.fetch(request)
            guard existing.isEmpty else { return }
            
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = name
            newCategory.trackers = NSSet()
            
            try context.save()
        } catch {
            print("Failed creating category: \(error)")
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
            trackerEntity.colorHex = tracker.color
            trackerEntity.schedule = tracker.schedule.map { $0.rawValue } as NSArray
            trackerEntity.category = categoryEntity
            return trackerEntity
        }
        
        let updatedTrackers = existingTrackers.union(newTrackerEntities)
        categoryEntity.trackers = NSSet(set: updatedTrackers)
        
        try context.save()
    }
    
    func delete(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        guard let categoryEntity = try context.fetch(request).first else { return }
        
        if let trackers = categoryEntity.trackers as? Set<TrackerCoreData> {
            for tracker in trackers {
                context.delete(tracker)
            }
            categoryEntity.trackers = nil
        }
        
        if categoryEntity.trackers == nil || (categoryEntity.trackers?.count ?? 0) == 0 {
            context.delete(categoryEntity)
        }
        
        try context.save()
    }
    
    func delete(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        let trackerEntities = try context.fetch(request)
        
        for trackerEntity in trackerEntities {
            if let category = trackerEntity.category {
                var trackers = (category.trackers as? Set<TrackerCoreData>) ?? []
                trackers.remove(trackerEntity)
                category.trackers = NSSet(set: trackers)
            }
            context.delete(trackerEntity)
        }
        
        try context.save()
    }
    
    func toggleTrackers(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        let existingCategories = try context.fetch(request)
        let categoryEntity: TrackerCategoryCoreData
        
        if let existing = existingCategories.first {
            categoryEntity = existing
        } else {
            try add(category)
            return
        }
        
        var currentTrackers = (categoryEntity.trackers as? Set<TrackerCoreData>) ?? []
        var modified = false
        
        for tracker in category.trackers {
            if let existingTracker = currentTrackers.first(where: { $0.id == tracker.id }) {
                context.delete(existingTracker)
                currentTrackers.remove(existingTracker)
                modified = true
            } else {
                let newTracker = TrackerCoreData(context: context)
                newTracker.id = tracker.id
                newTracker.name = tracker.name
                newTracker.emoji = tracker.emoji
                newTracker.colorHex = tracker.color
                newTracker.schedule = tracker.schedule.map { $0.rawValue } as NSArray
                newTracker.category = categoryEntity
                currentTrackers.insert(newTracker)
                modified = true
            }
        }
        
        if modified {
            categoryEntity.trackers = NSSet(set: currentTrackers)
            
            if currentTrackers.isEmpty {
                context.delete(categoryEntity)
            }
            
            try context.save()
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange(self)
    }
}
