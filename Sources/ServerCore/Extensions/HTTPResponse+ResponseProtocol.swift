//
//  HTTPResponse+ResponseProtocol.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Vapor
import Hammond

extension HTTPResponse: ResponseProtocol {

    public var statusCode: HTTPStatusCode {
        return HTTPStatusCode(rawValue: Int(status.code))
    }

    public var data: Data {
        return body.data ?? Data()
    }
}
