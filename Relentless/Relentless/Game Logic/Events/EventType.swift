//
//  EventType.swift
//  Relentless
//
//  Created by Yi Wai Chow on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum EventType: Int, Codable, CaseIterable {
    case appreciationEvent

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EventTypeKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .eventType)
        switch rawValue {
        case EventType.appreciationEvent.rawValue:
            self = .appreciationEvent
        default:
            throw EventTypeError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EventTypeKeys.self)
        switch self {
        case .appreciationEvent:
            try container.encode(EventType.appreciationEvent.rawValue, forKey: .eventType)
        }
    }
}

enum EventTypeKeys: CodingKey {
    case eventType
}

enum EventTypeError: Error {
    case unknownValue
}
