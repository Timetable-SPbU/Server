//
//  String+Cleanup.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 30/05/2018.
//

import Foundation

extension String {

  internal func cleanedUp() -> String {

    let trim = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)

    return trimmingCharacters(in: trim)
      .replacingOccurrences(of: "\\s+",
                                with: " ",
                                options: .regularExpression)
      .replacingOccurrences(of: "\\(\\s",
                            with: "(",
                            options: .regularExpression)
      .replacingOccurrences(of: "\\s\\)",
                            with: ")",
                            options: .regularExpression)
      .replacingOccurrences(of: "([.,:;!?…])([a-zA-Zа-яА-Я])",
                            with: "$1 $2",
                            options: .regularExpression)
      .replacingOccurrences(of: "\\s([.,:;!?…])",
                            with: "$1",
                            options: .regularExpression)

  }
}
