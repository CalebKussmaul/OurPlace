//
//  ColorBlock.swift
//  ourplace
//
//  Created by Caleb Kussmaul on 8/19/18.
//

import Foundation
import AppKit

class ColorBlock:Block {
  
  var color: String
  
  required override init(author: String, authorId: String, timestamp: Date) {
    fatalError("Init(author, timestamp) has not been implemented")
  }
  
  init(author: String, authorId: String, timestamp: Date, color: String) {
    self.color = color
    super.init(author: author, authorId: authorId, timestamp: timestamp)
  }
  
  override init?(json: [String: Any]) {
    if let color = json["color"] as? String {
      self.color = color
      super.init(json: json)
    }
    else {
      return nil
    }
  }
  
  override func type() -> BlockType {
    return .color
  }
  
  override func json() -> [String : Any] {
    var json = super.json()
    json["color"] = color
    return json
  }
  
}
