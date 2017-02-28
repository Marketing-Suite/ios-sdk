//
//  EMSRequestHandler.swift
//  Pods
//
//  Created by Paul Ballard on 1/20/17.
//
//

import Foundation
import Alamofire

struct RetryRequest
{
    var completion: RequestRetryCompletion
    var count: Int
}

class EMSRequestHandler: RequestRetrier {
    private let lock = NSLock()
    
    private var requestsToRetry : [String:RetryRequest] = [:]

    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        var interval: Double = 5
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 500 {
            if (request.retryCount == 0) { interval = 5 }
            else if (request.retryCount == 1) { interval = 30 }
            else if (request.retryCount == 2) { interval = 300 }
            else { completion(false, 0) }
            completion(true, interval)
        }
    }
}
