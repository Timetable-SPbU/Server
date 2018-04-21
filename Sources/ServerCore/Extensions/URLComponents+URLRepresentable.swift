//
//  URLComponents+URLRepresentable.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Foundation
import HTTP
import Vapor

extension URLComponents: HTTP.URLRepresentable, Vapor.URLRepresentable {
    public func convertToURL() -> URL? {
        return url
    }
}
