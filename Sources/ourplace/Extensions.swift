//
//  Extensions.swift
//  ourplace
//
//  Created by Caleb Kussmaul on 8/19/18.
//

import Foundation

extension Dictionary {
  func toJson() -> String? {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
      return String(data:jsonData, encoding: .ascii)
    } catch {
      return nil
    }
  }
  
  static func fromJson(json: String) -> [String: Any]? {
    if let data = json.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
}

extension Date {
  
  func iso() -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df.string(from: self)
  }
  
  static func fromIso(string: String) -> Date? {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df.date(from: string)
  }
}
