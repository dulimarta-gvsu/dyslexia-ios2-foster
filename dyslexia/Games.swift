//
//  Game.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/28/26.
//
import Foundation
import GRDB

struct Games: Codable, Identifiable, Hashable, Equatable, FetchableRecord, PersistableRecord, TableRecord {
    var id: Int64?
    var word: String
    var points: Int
    var time: Int
    var moves: Int
}
