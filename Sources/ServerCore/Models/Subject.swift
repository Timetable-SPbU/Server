//
//  Subject.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 31/05/2018.
//

import FluentPostgreSQL

public final class Subject: PostgreSQLModel, Migration {

  public var id: Identifier<Subject>?

  public var name: String

  public var isMandatory: Bool

  public var trajectory: String?
}
