//
//  ProxyPool.swift
//  TimetableDump
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Foundation
import Vapor

internal final class ProxyPool {

  private static let maxAttemptCount = 20

  private let logger: Logger
  private let client: Client
  private let container: Container

  private var lastSuccessfulConnection: HTTPClient?

  init(_ container: Container) throws {
    self.container = container
    client = try container.make(Client.self)
    logger = try container.make(Logger.self)
  }

  private func next(attemptCount: Int = 1) -> Future<HTTPClient> {

    return client
      .get("""
           https://gimmeproxy.com/api/getProxy?\
           get=true&supportsHttps=true&protocol=http&maxCheckPeriod=3000
           """)
      .flatMap(to: ProxyServer.self) { response in
        if response.http.status.code != 200 {
          let reason = """
          Proxy is unavailable: "\(response.http.status.reasonPhrase)\"
          """
          throw Abort(.serviceUnavailable,
                      reason: reason,
                      identifier: "unavailableProxy")
        } else {
          return try response.content.decode(ProxyServer.self)
        }
      }.flatMap(to: HTTPClient.self) { proxyServer in

        self.logger.debug("""
                          Connecting to the proxy server \(proxyServer.curl), \
                          attempt \(attemptCount)...
                          """)

        return HTTPClient.connect(scheme: .http,
                                  hostname: proxyServer.ip,
                                  port: proxyServer.port,
                                  on: self.container)
          .catchFlatMap { error in
            if attemptCount > ProxyPool.maxAttemptCount {
              throw error
            } else {
              // If we can't connect, try a different
              // proxy server.
              return self.next(attemptCount: attemptCount + 1)
            }
          }.do { connection in
            self.lastSuccessfulConnection = connection
          }
    }

  }

  private func proxy() -> Future<HTTPClient>  {
    return lastSuccessfulConnection
      .map { connection in
        container
          .eventLoop
          .newSucceededFuture(result: connection)
      } ?? next()
  }

  func send(_ request: HTTPRequest) -> Future<HTTPResponse> {

    func send(_ request: HTTPRequest,
              attemptCount: Int) -> Future<HTTPResponse> {
      return proxy().flatMap(to: HTTPResponse.self) { client in

        self.logger.debug("""
                          Sending request \(request), attempt \(attemptCount)...
                          """)

        return client.send(request)
      }.map(to: HTTPResponse.self) { response in
        if response.statusCode.category != .success {
          throw Abort(response.status)
        } else {
          return response
        }
      }.catchFlatMap { error in
        self.lastSuccessfulConnection = nil
        if attemptCount > ProxyPool.maxAttemptCount {
          throw error
        } else {
          // If we can't connect, try a different
          // proxy server.
          return send(request, attemptCount: attemptCount + 1)
        }
      }
    }

    return send(request, attemptCount: 1)
  }
}
