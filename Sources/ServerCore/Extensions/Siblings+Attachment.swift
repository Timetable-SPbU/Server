//
//  Siblings+Attachment.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Fluent

extension Siblings
    where Through: ModifiablePivot,
        Through.Left == Base,
        Through.Right == Related,
        Through.Database: QuerySupporting {

    /// Returns `true` if the model was attached to the relation.
    func attachIfNeeded(_ model: Related,
                        on conn: DatabaseConnectable) -> Future<Through> {

        return Future.flatMap(on: conn) { () -> Future<Through?> in
            try self.pivots(on: conn)
                .filter(Through.rightIDKey == model[keyPath: Related.idKey])
                .first()
        }.flatMap(to: Through.self) { pivot in
            if let pivot = pivot {
                return conn.eventLoop.newSucceededFuture(result: pivot)
            } else {
                return self.attach(model, on: conn)
            }
        }
    }
}
