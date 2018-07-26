//
//  Siblings+Attachment.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Fluent

extension Siblings
where Through:
  PostgreSQLPivot & ModifiablePivot,
  Through.Left == Base,
  Through.Right == Related
{
  /// Returns `true` if the model was attached to the relation.
  func attachIfNeeded(_ model: Related,
                      on connection: DatabaseConnectable) -> Future<Through> {

    return Future.flatMap(on: connection) {
      let pivot = try Through(self.base, model)
      return pivot.upsert(on: connection,
                          onConflict: Through.leftIDKey, Through.rightIDKey)
    }
  }
}
