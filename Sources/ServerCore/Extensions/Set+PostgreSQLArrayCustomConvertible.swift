//
//  Set+PostgreSQLArrayCustomConvertible.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import PostgreSQL

extension Set: PostgreSQLArrayCustomConvertible {

    /// See `PostgreSQLArrayCustomConvertible.postgreSQLDataArrayType`
    public static var postgreSQLDataArrayType: PostgreSQLDataType {
        fatalError("Multi-dimensional arrays are not yet supported.")
    }

    /// See `PostgreSQLDataCustomConvertible.postgreSQLDataType`
    public static var postgreSQLDataType: PostgreSQLDataType {
        return requirePostgreSQLDataCustomConvertible(Element.self)
            .postgreSQLDataArrayType
    }

    /// See `PostgreSQLArrayCustomConvertible.PostgreSQLArrayElement`
    public typealias PostgreSQLArrayElement = Element

    /// See `PostgreSQLArrayCustomConvertible.convertFromPostgreSQLArray(_:)`
    public static func convertFromPostgreSQLArray(
        _ data: [Element]
    ) -> Set<Element> {
        return Set(data)
    }

    /// See `PostgreSQLArrayCustomConvertible.convertToPostgreSQLArray(_:)`
    public func convertToPostgreSQLArray() -> [Element] {
        return Array(self)
    }
}

// Dynamic casting for conditional conformances must be supported in Swift 5
#if swift(>=5)
#else
func requirePostgreSQLDataCustomConvertible<T>(
    _ type: T.Type
) -> PostgreSQLDataConvertible.Type {
    guard let custom = T.self as? PostgreSQLDataConvertible.Type else {
        fatalError(
            "`\(T.self)` does not conform to `PostgreSQLDataCustomConvertible`"
        )
    }
    return custom
}
#endif
