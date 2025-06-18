//
//  FilterType.swift
//  Tracker
//
//  Created by mpplokhov on 18.06.2025.
//

import Foundation

enum FilterType: Int, CaseIterable {
    case all = 0
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: return NSLocalizedString("all_trackers", comment: "")
        case .today: return NSLocalizedString("trackers_today", comment: "")
        case .completed: return NSLocalizedString("completed", comment: "")
        case .notCompleted: return NSLocalizedString("incomplete", comment: "")
        }
    }
}
