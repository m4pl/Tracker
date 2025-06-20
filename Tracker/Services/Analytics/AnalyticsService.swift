//
//  AnalyticsService.swift
//  Tracker
//
//  Created by mpplokhov on 18.06.2025.
//

import UIKit
import YandexMobileMetrica

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

final class AnalyticsService {

    static func activateAppMetrica() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "acaae5d9-de05-4578-92f5-ff7e7e0d27c9") else {
            assertionFailure("Failed to create AppMetrica configuration")
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }

    static func log(event: AnalyticsEventType, screen: String, item: String? = nil) {
        var eventData: [String: Any] = [
            "event": event.rawValue,
            "screen": screen
        ]

        if let item = item {
            eventData["item"] = item
        }

        YMMYandexMetrica.reportEvent("custom_event", parameters: eventData, onFailure: { error in
            print("AppMetrica error: \(error.localizedDescription)")
        })

        print("[Analytics] Event: \(event.rawValue), Screen: \(screen), Item: \(item ?? "nil")")
    }
}
