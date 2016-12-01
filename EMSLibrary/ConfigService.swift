//
//  ConfigService.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 5/10/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import Foundation


public class ConfigService:NSObject  {

    public var session = NSURLSession.sharedSession()

    
    public override init() {
        
    }
    
    public func taskForGETMethod(configData: ConfigData, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let URL = NSURL(string: "http://\(configData.environment)/xts/registration/cust/\(configData.customerId )/application/\(configData.applicationId )/token/\(configData.deviceToken )")
        
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "GET"

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
                sendError("No data was returned by the request!")
        }
        
        task.resume()
        
        return task
    }
    
}
