//
//  ScheduleModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2022 OPass.
//

import Foundation
import SwiftDate

struct ScheduleModel: Hashable, Codable {
    @TransformWith<SessionModelsTransform> var sessions = []
    @TransformWith<SpeakerTransform> var speakers = [:]
    @TransformWith<Id_Name_DescriptionTransform> var session_types = [:]
    @TransformWith<Id_Name_DescriptionTransform> var rooms = [:]
    @TransformWith<TagsTransform> var tags = TagsModel()
}

struct SessionModelsTransform: TransformFunction {
    static func transform(_ sessions: [SessionDataModel]) -> [SessionModel] {
        return sessions
            .grouped(by: { [$0.start.year, $0.start.month, $0.start.day] })
            .sorted(by: { entry1, entry2 in
                let day1 = entry1.key
                let day2 = entry2.key
                if day1[0] != day2[0] {
                    return day1[0] < day2[0]
                } else if day1[1] != day2[1] {
                    return day1[1] < day2[1]
                } else {
                    return day1[2] < day2[2]
                }
            })
            .map { (_, session) in session }
            .map { $0.grouped(by: \.start) }
            .map { sessionsDict in
                SessionModel(header: Array(sessionsDict.keys.sorted()), data: sessionsDict)
            }
    }
}

fileprivate extension Sequence {
    func grouped<K>(by keyPath: KeyPath<Element, K>) -> Dictionary<K, [Element]> {
        return grouped(by: { $0[keyPath: keyPath] })
    }
    func grouped<K>(by key: ((Element) -> K)) -> Dictionary<K, [Element]> {
        Dictionary(grouping: self, by: key)
    }
}

struct SessionModel: Hashable, Codable {
    var header: [DateInRegion] = []
    var data: [DateInRegion : [SessionDataModel]] = [:]
}

struct SessionDataModel: Hashable, Codable {
    var id: String = ""
    var type: String? = nil
    var room: String = ""
    var broadcast: [String]? = nil
    @TransformedFrom<String> var start = DateInRegion()
    @TransformedFrom<String> var end = DateInRegion()
    var qa: String? = nil
    var slide: String? = nil
    var live: String? = nil
    var record: String? = nil
    var pad: String? = nil
    var language: String? = nil
    var zh = Title_DescriptionModel()
    var en = Title_DescriptionModel()
    var speakers: [String] = [""]
    var tags: [String] = [""]
}

struct SpeakerTransform: TransformFunction {
    static func transform(_ speakers: [Id_SpeakerModel]) -> [String: SpeakerModel] {
        return Dictionary(uniqueKeysWithValues: speakers.map { element in
            (element.id, SpeakerModel(avatar: element.avatar, zh: element.zh, en: element.zh))
        })
    }
}

struct TagsTransform: TransformFunction {
    static func transform(_ array: [Id_Name_DescriptionModel]) -> TagsModel {
        return TagsModel(
            id: array.map { $0.id },
            data: Dictionary(uniqueKeysWithValues: array.map { element in
                (element.id, Name_DescriptionPair(zh: element.zh, en: element.en))
            }))
    }
}

struct TagsModel: Hashable, Codable {
    var id: [String] = []
    var data: [String: Name_DescriptionPair] = [:]
}

struct Id_Name_DescriptionTransform: TransformFunction {
    static func transform(_ array: [Id_Name_DescriptionModel]) -> [String: Name_DescriptionPair] {
        return Dictionary(uniqueKeysWithValues: array.map { element in
            (element.id, Name_DescriptionPair(zh: element.zh, en: element.en))
        })
    }
}

extension String: TransformSelf {
    static func transform(_ dateString: String) -> DateInRegion {
        return dateString.toISODate()!
    }
}

struct Id_SpeakerModel: Hashable, Codable {
    var id: String = ""
    var avatar: String = ""
    var zh = Name_BioModel()
    var en = Name_BioModel()
}

struct SpeakerModel: Hashable, Codable {
    var avatar: String = ""
    var avatarData: Data?
    var zh = Name_BioModel()
    var en = Name_BioModel()
}

struct Id_Name_DescriptionModel: Hashable, Codable {
    var id: String = ""
    var zh = Name_DescriptionModel()
    var en = Name_DescriptionModel()
}

struct Title_DescriptionModel: Hashable, Codable {
    var title: String = ""
    var description: String = ""
}

struct Name_BioModel: Hashable, Codable {
    var name: String = ""
    var bio: String = ""
}

struct Name_DescriptionPair: Hashable, Codable {
    var zh: Name_DescriptionModel
    var en: Name_DescriptionModel
}

struct Name_DescriptionModel: Hashable, Codable {
    var name: String = ""
    var description: String? = nil
}
