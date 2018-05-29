//
//  PartialKeyPath+QueryField.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 29/05/2018.
//

import Fluent

extension PartialKeyPath where Root: Model {

  public func makeQueryFieldPartial() throws -> QueryField {

    guard let key = try Root
      .anyReflectProperty(valueType: type(of: self).valueType,
                          keyPath: self) else {
      throw FluentError(identifier: "reflectProperty",
                        reason: "No property reflected for \(self)",
                        source: .capture())
    }

    return QueryField(entity: Root.entity, name: key.path.first ?? "")
  }
}
