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
                        on conn: DatabaseConnectable) -> Future<Bool> {

        return isAttached(model, on: conn)
            .flatMap(to: Bool.self) { isAttached in
                if !isAttached {
                    return self.attach(model, on: conn).transform(to: true)
                } else {
                    return conn.eventLoop.newSucceededFuture(result: false)
                }
            }
    }
}
