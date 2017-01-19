//
//  EMSCommsError.swift
//  Pods
//
//  Created by Paul Ballard on 1/16/17.
//
//

import Foundation

public enum EMSCommsError : Error
{
    case invalidRequest
    case notAuthenticated(userName: String)
    case notAuthorized(userName: String)
    case notFound(url: URL)
    case serverError(message: String)
}
