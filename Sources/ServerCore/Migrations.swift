//
//  Migrations.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 29/05/2018.
//

import Fluent

extension MigrationConfig {

  public static func addAllMigrations() -> MigrationConfig {

    var migrations = MigrationConfig()

    migrations.add(migration: DivisionType.self, database: .psql)
    migrations.add(model: Division.self, database: .psql)
    migrations.add(model: StudyLevel.self, database: .psql)
    migrations.add(model: DivisionStudyLevel.self, database: .psql)
    migrations.add(model: Specialization.self, database: .psql)
    migrations.add(model: StudentStream.self, database: .psql)
    migrations.add(model: StudentGroup.self, database: .psql)
    migrations.add(model: Educator.self, database: .psql)

    return migrations
  }
}
