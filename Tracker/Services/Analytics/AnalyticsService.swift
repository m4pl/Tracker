//
//  AnalyticsService.swift
//  Tracker
//
//  Created by mpplokhov on 18.06.2025.
//

import AppMetricaCore

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

class AnalyticsService {

    static func log(event: AnalyticsEventType, screen: String, item: String? = nil) {
        var eventData: [String: Any] = [
            "event": event.rawValue,
            "screen": screen
        ]

        if let item = item {
            eventData["item"] = item
        }

        AppMetrica.reportEvent(name: "custom_event", parameters: eventData, onFailure: { error in
            print("AppMetrica error: \(error.localizedDescription)")
        })

        print("[Analytics] Event: \(event.rawValue), Screen: \(screen), Item: \(item ?? "nil")")
    }
}
