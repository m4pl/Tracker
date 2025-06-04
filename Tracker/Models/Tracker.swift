//
//  Tracker.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
