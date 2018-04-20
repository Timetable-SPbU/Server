//
//  PostgreSQLModel.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 18/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor

/// Reimplementation of `FluentPostgreSQL.FluentPostgreSQL`
/// with strongly typed ID.
public protocol PostgreSQLModel: Model
    where Self.Database == PostgreSQLDatabase {

    /// This model's unique identifier.
    var id: Identifier<Self>? { get set }
}

extension PostgreSQLModel where Self.ID == Identifier<Self>  {
    public static var idKey: IDKey { return \.id }
}

public protocol PostgreSQLPivot: Pivot, PostgreSQLModel { }

