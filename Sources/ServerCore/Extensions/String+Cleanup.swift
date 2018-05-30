//
//  String+Cleanup.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 30/05/2018.
//

import Foundation

extension String {

  internal func cleanedUp() -> String {
    return replacingOccurrences(of: "\\s+",
                                with: " ",
                                options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
