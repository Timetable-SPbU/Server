//
//  ProxyServer.swift
//  TimetableDump
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Foundation
import Hammond

internal struct ProxyServer: Decodable {

  /// Whether the proxy server supports GET requests.
  var get: Bool

  /// Whether the proxy server supports POST requests.
  var post: Bool

  /// Whether the proxy server supports HTTPS.
  var supportsHttps: Bool

  /// The proxy protocol.
  var `protocol`: String

  /// The proxy IP.
  var ip: String

  /// The proxy port.
  var port: Int

  var curl: URL

  private enum CodingKeys: String, CodingKey {
    case get            = "get"
    case post           = "post"
    case supportsHttps  = "supportsHttps"
    case `protocol`     = "protocol"
    case ip             = "ip"
    case port           = "port"
    case curl           = "curl"
  }

  init(from decoder: Decoder) throws {

    let container = try decoder.container(keyedBy: CodingKeys.self)

    get = try container.decode(Bool.self, forKey: .get)
    post = try container.decode(Bool.self, forKey: .post)
    supportsHttps = try container.decode(Bool.self, forKey: .supportsHttps)
    `protocol` = try container.decode(String.self, forKey: .protocol)
    ip = try container.decode(String.self, forKey: .ip)

    if let port = Int(try container.decode(String.self, forKey: .port)) {
      self.port = port
    } else {
      self.port = try container.decode(Int.self, forKey: .port)
    }

    curl = try container.decode(URL.self, forKey: .curl)
  }
}
