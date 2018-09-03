//
//  World.swift
//  CHTTPParser
//
//  Created by Caleb Kussmaul on 8/19/18.
//

import Foundation

class Coord: Hashable {

  let x: Int
  let y: Int
  
  public init(_ x:Int, _ y: Int) {
    self.x = x
    self.y = y
  }
  
  static func == (lhs: Coord, rhs: Coord) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
  var hashValue: Int {
    return (31 &* x.hashValue) &+ y.hashValue
  }
  
  var toString:String {
    return String(x) + "," + String(y)
  }
}

public final class World {
  
  public static var instance: World = World()
  
  var blocks: [Coord: Block]
  var timeouts: [String: Date]
  
  private final let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("game.json")
  
  private init() {
    blocks = [:]
    timeouts = [:]
    
    guard let data = try? String(contentsOf: url), let json = [String: Any].fromJson(json: data) else {
      return
    }
    guard let blocksJson = json["blocks"] as? [[String: Any]], let timeoutsJson = json["timeouts"] as? [String: Any] else {
      return;
    }
    for jsonBlock in blocksJson {
      if let block = Block.from(json: jsonBlock) {
        if let x = jsonBlock["x"] as? Int, let y = jsonBlock["y"] as? Int {
          blocks[Coord(x,y)] = block
        }
      }
    }
    for (user, isoTimeout) in timeoutsJson {
      if let isoTimeout = isoTimeout as? String {
        timeouts[user] = Date.fromIso(string: isoTimeout)
      }
    }
  }
  
  func save() {
    let _ = try? privateJson().toJson()?.write(to: url, atomically: true, encoding: .utf8)
  }
  
  private func blocksJson(includeUserIds: Bool) -> [[String: Any]] {
    var jsonBlocks: [[String: Any]] = []
    for (coord, block) in blocks {
      var json = includeUserIds ? block.privateJson() : block.json()
      json["x"] = coord.x
      json["y"] = coord.y
      jsonBlocks.append(json)
    }
    return jsonBlocks
  }
  
  func json(for user: String?) -> [String: Any?] {
    
    var timeout: Date?
    if let user = user, let userTimeout = timeouts[user] {
      timeout = userTimeout
    } else {
      timeout = nil
    }
    return ["timeout": (timeout?.iso() ?? nil),
            "blocks": blocksJson(includeUserIds: false)]
  }
  
  func privateJson() -> [String: Any] {
    var jsonTimeouts: [String: Any] = [:]
    for (user, timeout) in timeouts {
      jsonTimeouts[user] = timeout.iso()
    }
    return ["timeouts": jsonTimeouts,
            "blocks": blocksJson(includeUserIds: true)]
  }
  
  func place(x: Int, y: Int, block: Block, authorId: String) -> (Bool, Date) {
    let now = Date()
    if let timeout = timeouts[authorId], now < timeout {
      return (false, timeout)
    }
    blocks[Coord(x, y)] = block
    let newTimeout = now.addingTimeInterval(5 * 60.0)
    timeouts[authorId] = newTimeout
    return (true, newTimeout)
  }
}
