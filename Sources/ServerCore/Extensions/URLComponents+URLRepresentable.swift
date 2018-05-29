//
//  URLComponents+URLRepresentable.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Foundation
import HTTP
import Vapor

extension URLComponents: URLRepresentable {
  public func convertToURL() -> URL? {
    return url
  }
}
