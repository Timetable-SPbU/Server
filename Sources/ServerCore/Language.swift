//
//  Language.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 17/04/2018.
//

import Vapor

public enum Language: String, Codable {
    case en
    case ru
}

extension Language {
    public static let `default` = Language.ru
}

extension Request {

    public var preferredLanguage: Language {

        do {
            return try query.get(Language.self, at: "lang")
        } catch {

            // The user hasn't specified a preferred language,
            // fall back to HTTP headers.

            let headers = http.headers

            if let language = headers[.acceptLanguage].first {

                if language.starts(with: "en") {
                    return .en
                } else if language.starts(with: "ru") {
                    return .ru
                } else {
                    return .default
                }
            } else {
                return .default
            }
        }
    }
}
