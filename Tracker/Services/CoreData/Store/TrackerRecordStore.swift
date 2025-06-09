//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import Foundation
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
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
    
    func getRecords() -> [TrackerRecord] {
        guard let records = fetchedResultsController.fetchedObjects else { return [] }
        
        return records.compactMap { record in
            guard let tracker = record.tracker,
                  let trackerId = tracker.id,
                  let date = record.date
            else { return nil }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    func getRecords(for trackerId: UUID) -> [TrackerRecord] {
        return getRecords().filter { $0.trackerId == trackerId }
    }
    
    func add(_ record: TrackerRecord) throws {
        let entity = TrackerRecordCoreData(context: context)
        entity.date = record.date
        
        let trackerRequest = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        
        guard let trackerEntity = try context.fetch(trackerRequest).first else {
            throw StoreError.trackerNotFound
        }
        
        entity.tracker = trackerEntity
        
        try context.save()
    }

    func delete(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "date == %@", record.date as NSDate),
            NSPredicate(format: "tracker.id == %@", record.trackerId as CVarArg)
        ])

        let results = try context.fetch(request)
        for object in results {
            context.delete(object)
        }
        
        try context.save()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChange(self)
    }
}
