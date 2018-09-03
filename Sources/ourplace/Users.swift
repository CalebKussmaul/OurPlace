//
//  Users.swift
//  ourplace
//
//  Created by Caleb Kussmaul on 8/23/18.
//

import Foundation
import SwiftKuery
import KituraSession
import SwiftKuerySQLite

class SessionTable: Table {
  let tableName = "sessions"
  let id = Column("id", String.self, primaryKey: true)
  let data = Column("data", String.self)
}

class Sessions: Store {
  
  private var connection:Connection {
    return DB.pool.getConnection()!
  }
  
  func load(sessionId: String, callback: @escaping (Data?, NSError?) -> Void) {
    let query = Select(DB.sessions.data, from: DB.sessions).where(DB.sessions.id == sessionId)
    connection.execute(query: query) { result in
      guard result.success else {
        callback(nil, result.asError as NSError?)
        return
      }
      
      if let row = result.asRows?.first {
        if let base64String = row[DB.sessions.data.name] as? String, let decodedData = Data(base64Encoded: base64String) {
          callback(decodedData, nil)
          return
        }
      }
      callback(nil, nil)
    }
  }
  
  func save(sessionId: String, data: Data, callback: @escaping (NSError?) -> Void) {
    delete(sessionId: sessionId) {
      error in
      let query = Insert(into: DB.sessions, rows: [[sessionId, data.base64EncodedString()]])
      self.connection.execute(query: query) { result in
        guard result.success else {
          callback(result.asError as NSError?)
          return
        }
        callback(nil)
      }
    }
  }
  
  func touch(sessionId: String, callback: @escaping (NSError?) -> Void) {
    callback(nil)
  }
  
  func delete(sessionId: String, callback: @escaping (NSError?) -> Void) {
    let query = Delete(from: DB.sessions, where: DB.sessions.id == sessionId)
    connection.execute(query: query) { result in
      guard result.success else {
        callback(result.asError as NSError?)
        return
      }
      callback(nil)
    }
  }
}

class DB {
  public static let pool = SQLiteConnection.createPool(filename: "Users.db", poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 30, timeout: 10000))
  public static let sessions = SessionTable()
  
  static func deleteDB() {
    try? FileManager().removeItem(atPath: "Users.db")
  }
  
  static func setup() {
    //print(FileManager().currentDirectoryPath)
    if let connection = pool.getConnection() {
      sessions.create(connection: connection) { result in
        guard result.success else {
          return
        }
      }
      connection.closeConnection()
    }
  }
}



