import Routing
import Vapor
import ServerCore

/// Called after the application has initialized.
public func boot(_ app: Application) throws {

  _ = app.eventLoop.scheduleTask(in: .hours(8)) { () -> Void in
    // TODO: Dump timetable.spbu.ru.

//    app.requestPooledConnection(to: .psql)
//      .map(to: Void.self) { connection in
//
//        let dumper = TimetableDumper(container: app,
//                                     databaseConnectable: connection)
//
//    }
  }
}
