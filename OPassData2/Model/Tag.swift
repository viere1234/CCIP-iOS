//
//  Tag.swift
//  
//
//  Created by Brian Chang on 2024/4/29.
//

import Foundation

public struct Tag: Codable, Identifiable, Localizable {
    public var id: String
    public var zh: TagDetail
    public var en: TagDetail
}

public struct TagDetail: Hashable, Codable {
    public var name: String
    public var description: String?
}
