//
//  PostOpenEMS.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 9/26/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PostOpenEMSListener: NSObjectProtocol

public protocol PostOpenEMSListener: NSObjectProtocol {
    func successPostOpenEMS(json: NSDictionary)
    func failurePostOpenEMS(jsonError: String)
}

// MARK: - PostOpenEMS:NSObject

public class PostOpenEMS:NSObject {
    
    // Listener passed in by the owning object
    public var listener : PostOpenEMSListener?
    
     public override init() {}
    // Assign listener implementing events interface that will receive the events (passed in by the owner)
    public func setPostOpenEMSListener( listener: PostOpenEMSListener) {
        self.listener = listener
    }
    
    public func postID( cr:String, s_msg_id:String, fm:String, s_camp_id:String) {
    
    // OS Version
        let systemVersion = UIDevice.currentDevice().systemVersion
        let s_os_version:String = systemVersion
    
    // Response Time Date YYYY-MM-DDThh:mm:ssTZD
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let s_response_time:String = formatter.stringFromDate(now)
    
    // Reference OPen URL: http://cs.sbox.eccmp.com/ats/post.aspx?cr=100&fm=63&s_platform_name=iPhone%20OS&s_os_version=9.0&s_camp_id=111&s_response_time=20160913%2013:55&s_msg_id=222
    
        let openURL:String = "http://cs.sbox.eccmp.com/ats/post.aspx?cr=" + cr + "&fm=" + fm + "&s_platform_name=iOS%20OS&s_os_version=" + s_os_version + "&s_camp_id=" + s_camp_id +
    "&s_response_time=" + s_response_time + "&s_msg_id=" + s_msg_id;
        
        let requestURL = NSURL(string: openURL)
        let urlRequest = NSMutableURLRequest(URL: requestURL!)
        urlRequest.HTTPMethod = "GET"
        //ok
        let session = NSURLSession.sharedSession()
        
        let taskAsynch = session.dataTaskWithRequest(urlRequest, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            
            print( response)
            
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                let allHeaderFields = (response as! NSHTTPURLResponse).allHeaderFields
                let responseHTTP = response as! NSHTTPURLResponse
                print(allHeaderFields)
                print(responseHTTP)
                
                if(statusCode == 200 || statusCode == 201) {
                    
                    let datastring = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    
                    let parts = datastring!.componentsSeparatedByString("<json>")
                    //ok
                    let messages =  "\(parts)"
                    
                    
                    let responseText = "GET Succeeded: HTTP \(statusCode), Response: \(messages)"
                    print( responseText)
                }
                else
                {
                    let responseText = "URL POST Session Task Failed: HTTP \(statusCode), Response: \(response!)"
                    print( responseText)
                }
            }
            else {
                // Failure
                print("URL POST Session Task Failed: %@", error!.localizedDescription);
                let responseText = "URL POST Session Task Failed: \(error!.localizedDescription)"
                print(responseText)
            }
        })
        
        taskAsynch.resume()
    }
}
