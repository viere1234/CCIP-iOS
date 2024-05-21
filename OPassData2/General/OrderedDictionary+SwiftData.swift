//
//  OrderedDictionary+SwiftData.swift
//
//
//  Created by Brian Chang on 2024/5/4.
//

import SwiftData
import OrderedCollections

extension OrderedDictionary: SwiftData.RelationshipCollection where Value: SwiftData.RelationshipCollection {
    public typealias PersistentElement = Value.PersistentElement
}
