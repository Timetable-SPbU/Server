//
//  StudentGroup.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 29/05/2018.
//

import Fluent
import FluentPostgreSQL
import PostgreSQL

public final class StudentGroup: PostgreSQLModel {

  public var id: Identifier<StudentGroup>?


}

extension StudentGroup: Migration {

}
