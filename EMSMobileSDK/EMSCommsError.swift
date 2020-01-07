//
//  EMSCommsError.swift
//  Pods
//
//  Created by Paul Ballard on 1/16/17.
//
//

import Foundation
/// This enum is used to represent the various types of communications errors that can occur during calls to CCMP
public enum EMSCommsError: Error {
    case invalidRequest
    case notAuthenticated(userName: String)
    case notAuthorized(userName: String)
    case notFound(url: URL)
    case serverError(message: String)
}
