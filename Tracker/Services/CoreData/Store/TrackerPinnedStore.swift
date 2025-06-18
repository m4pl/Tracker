//
//  TrackerPinnedStore.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import Foundation
import CoreData

protocol TrackerPinnedStoreDelegate: AnyObject {
    func trackerPinnedStoreDidChange(_ store: TrackerPinnedStore)
}

final class TrackerPinnedStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerPinnedCoreData>!
    
    weak var delegate: TrackerPinnedStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerPinnedCoreData> = TrackerPinnedCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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

    func getPinned() -> [PinnedTracker] {
        guard let pinnedEntities = fetchedResultsController.fetchedObjects else { return [] }
        
        return pinnedEntities.compactMap { entity in
            guard let trackerEntity = entity.tracker,
                  let id = trackerEntity.id,
                  let name = trackerEntity.name,
                  let colorHex = trackerEntity.colorHex,
                  let emoji = trackerEntity.emoji,
                  let schedule = trackerEntity.schedule as? [Int],
                  let date = entity.date
            else { return nil }

            let tracker = Tracker(
                id: id,
                name: name,
                color: colorHex,
                emoji: emoji,
                schedule: schedule.compactMap { WeekDay(rawValue: $0) }
            )

            return PinnedTracker(
                tracker: tracker,
                date: date
            )
        }
    }

    func add(_ pinnedTracker: PinnedTracker) throws {
        let pinnedEntity = TrackerPinnedCoreData(context: context)
        pinnedEntity.date = pinnedTracker.date

        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", pinnedTracker.tracker.id as CVarArg)

        guard let trackerEntity = try context.fetch(trackerRequest).first else {
            throw StoreError.trackerNotFound
        }

        pinnedEntity.tracker = trackerEntity

        try context.save()
    }

    func delete(_ pinnedTracker: PinnedTracker) throws {
        let request: NSFetchRequest<TrackerPinnedCoreData> = TrackerPinnedCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "date == %@", pinnedTracker.date as NSDate),
            NSPredicate(format: "tracker.id == %@", pinnedTracker.tracker.id as CVarArg)
        ])

        let results = try context.fetch(request)
        for object in results {
            context.delete(object)
        }

        try context.save()
    }

    func toggle(_ pinnedTracker: PinnedTracker) throws {
        let request: NSFetchRequest<TrackerPinnedCoreData> = TrackerPinnedCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", pinnedTracker.tracker.id as CVarArg)
        ])

        let results = try context.fetch(request)

        if results.isEmpty {
            try add(pinnedTracker)
        } else {
            for object in results {
                context.delete(object)
            }
            try context.save()
        }
    }
}

extension TrackerPinnedStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerPinnedStoreDidChange(self)
    }
}
