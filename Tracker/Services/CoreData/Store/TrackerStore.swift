//
//  TrackerStore.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import Foundation
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
    
    func getTrackers() throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        
        let results = try context.fetch(request)
        
        return results.compactMap { coreData in
            guard let id = coreData.id,
                  let name = coreData.name,
                  let emoji = coreData.emoji,
                  let colorHex = coreData.colorHex,
                  let scheduleData = coreData.schedule as? [Int]
            else { return nil }
            
            return Tracker(
                id: id,
                name: name,
                color: colorHex,
                emoji: emoji,
                schedule: scheduleData.compactMap { WeekDay(rawValue: $0) }
            )
        }
    }
    
    func add(_ tracker: Tracker) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color
        entity.schedule = tracker.schedule.map { $0.rawValue } as NSArray
        
        try context.save()
    }
    
    func delete(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let object = try context.fetch(request).first {
            context.delete(object)
            try context.save()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChange(self)
    }
}
