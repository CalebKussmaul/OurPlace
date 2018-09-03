//
//  Block.swift
//  CHTTPParser
//
//  Created by Caleb Kussmaul on 8/19/18.
//



import Foundation

enum BlockType:String {
  case color = "color"
}

class Block {
  
  var author: String
  var authorId: String
  var timestamp: Date
  
  private static var dateFormatter: DateFormatter = {
    
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df
  }()

  init(author: String, authorId: String, timestamp: Date) {
    self.author = author
    self.authorId = authorId
    self.timestamp = timestamp
  }
  
  init?(json: [String: Any]) {
    
    if let author = json["author"] as? String, let authorId = json["authorId"] as? String {
      self.author = author
      self.authorId = authorId
    } else {
      return nil
    }
    if let timestampStr = json["timestamp"] as? String, let time = Block.dateFormatter.date(from: timestampStr) {
      self.timestamp = time
    } else {
      self.timestamp = Date()
    }
  }
  
  
  func tick(world: World) {
    
  }
  
  func type() -> BlockType {
    return .color
  }
  
  func json() -> [String: Any] {
    return ["author":author,
            "timestamp":Block.dateFormatter.string(from: timestamp),
            "type": self.type().rawValue]
  }
  
  func privateJson() -> [String: Any] {
    var json = self.json()
    json["authorId"] = authorId
    return json
  }
  
  static func from(json: [String: Any]) -> Block? {
    guard let typeStr = json["type"] as? String, let type = BlockType(rawValue: typeStr) else {
      return nil
    }
    switch type {
    case .color:
      return ColorBlock(json: json)
    }
  }
}
