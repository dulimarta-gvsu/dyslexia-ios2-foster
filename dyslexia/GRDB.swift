//
//  GRDB.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/28/26.
//

import Foundation
import GRDB

var AppDatabase: DatabaseManager!

class DatabaseManager {
    let dbQueue: DatabaseQueue
    
    static func initialize() {
        AppDatabase = try! DatabaseManager()
    }
    
    func getInstance () -> DatabaseManager {
        return self
    }
    
    private init() throws {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let dbURL = appSupportURL.appendingPathComponent("db.sqlite")
        
        dbQueue = try DatabaseQueue(
            path: dbURL.path
        )
        
        try migrator.migrate(dbQueue)
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { db in
            try db.create(table: "games") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("word", .text).notNull()
                t.column("points", .integer).notNull()
                t.column("time", .integer).notNull()
                t.column("moves", .integer).notNull()
            }
        }
        
        return migrator
    }
}

extension DatabaseManager {
    func save(_ game: Games) async throws {
        try await dbQueue.write { db in
            try game.save(db)
        }
    }
}


