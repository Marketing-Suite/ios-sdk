//
//  PostGetData.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 9/26/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PostGetDataListener: NSObjectProtocol

public protocol PostGetDataListener: NSObjectProtocol {
    
    func successSaveData(response: String)
    func failureSaveData(error: String)
    
    func successGetData(response: String)
    func failureGetData(error: String)
}

// MARK: - PostGetData: NSObject

public class PostGetData: NSObject {
    
    // Listener passed in by the owning object
    public var listener : PostGetDataListener?
    
    public override init() {}
    // Assign listener implementing events interface that will receive the events (passed in by the owner)
    func setPostGetDataListener( listener: PostGetDataListener) {
        self.listener = listener
    }
    
    public func saveData () -> Void{
        
        // Default Data
        let emsPush:EMSPush = EMSPush()
        
        let cr:String = emsPush.getCustomerID()
        let fm:String = emsPush.getFM()
        let s_user_id:String = emsPush.getsUserID()
        let s_message_id:String = emsPush.getsMessageID()
        let s_message = emsPush.getsMessage()
        let s_mobile_token:String = emsPush.getsMobileToken()
        //let wu:String = emsPush.getWU()
        let custom_params:String = emsPush.getCustomParam()
        let endPoint:String = emsPush.getEndPoint()

        // Reference: http://cs.sbox.eccmp.com/ats/post.aspx?cr=100&fm=55&s_user_id=2&s_message=Message%20for%20user%202%202016-10-31T21:18:06%2B00:00&s_message_id=1&s_mobile_token=2
        
        var baseUrl:String = "http://" + endPoint + "/ats/post.aspx?cr=" + cr + "&fm=" + fm + "&s_user_id=" + s_user_id +
            "&s_message=" + s_message + "&s_message_id=" + s_message_id + "&s_mobile_token=" + s_mobile_token;
        
        // Add custom params if exists
        if (custom_params.characters.count > 0 ) {
            baseUrl = baseUrl + custom_params
        }
        
        print(baseUrl)
        //endPointTextOutlet.text = stringURL
        
        let requestURL = NSURL(string: baseUrl)
        let urlRequest = NSMutableURLRequest(URL: requestURL!)
        urlRequest.HTTPMethod = "POST"
        
        //urlRequest.HTTPBody = baseUrl.dataUsingEncoding(NSUTF8StringEncoding);
        
        let session = NSURLSession.sharedSession()
        
        let taskAsynch = session.dataTaskWithRequest(urlRequest, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                let allHeaderFields = (response as! NSHTTPURLResponse).allHeaderFields
                let responseHTTP = response as! NSHTTPURLResponse
                print(allHeaderFields)
                print(responseHTTP)
                
                if(statusCode == 200 || statusCode == 201) {
                    
                    let responseText = "URL POST Session Task Succeeded: HTTP \(statusCode), Response: \(response!)"
                    print( responseText)
                    
                   self.listener!.successSaveData(responseText)
                }
                else
                {
                    let responseText = "URL POST Session Task Failed: HTTP \(statusCode), Response: \(response!)"
                    print( responseText)

                    self.listener!.failureSaveData(responseText)
                }
            }
            else {
                // Failure
                
                self.listener!.failureSaveData("URL POST Session Task Failed: \(error!.localizedDescription)")
            }
        })
        
        taskAsynch.resume()
    }
    
    public func getData () -> Void{
        
        // Default Data
        let emsPush:EMSPush = EMSPush()
        
        let cr:String = emsPush.getCustomerID()
        //let fm:String = emsPush.getFM()
        let s_user_id:String = emsPush.getsUserID()
        //let s_message_id:String = emsPush.getsMessageID()
        //let s_message = emsPush.getsMessage()
        let s_mobile_token:String = emsPush.getsMobileToken()
        let wu:String = emsPush.getWU()
        let custom_params:String = emsPush.getCustomParam()
        let endPoint:String = emsPush.getEndPoint()
        
        var baseUrl:String = "http://" + endPoint + "/ats/url.aspx?cr=" + cr + "&wu=" + wu + "&uid=" + s_user_id + "&mtok=" + s_mobile_token
        
        // Add custom params if exists
        if (custom_params.characters.count > 0 ) {
            baseUrl = baseUrl + custom_params
        }

        let requestURL = NSURL(string: baseUrl)
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
                   
                    let datastring = String(data: data!, encoding: NSUTF8StringEncoding)
                    print(datastring)
                    
                    // Get Messages
                    let responseTextSub = self.getSubString(datastring!, startString: "<json>", endString: "</json>")
                    self.listener!.successGetData(responseTextSub)
                }
                else
                {
                    let responseText = "URL POST Session Task Failed: HTTP \(statusCode), Response: \(response!)"
                    print( responseText)
                    
                    self.listener!.failureGetData(responseText)
                }
            }
            else {
                // Failure
                print("URL POST Session Task Failed: %@", error!.localizedDescription);
                let responseText = "URL POST Session Task Failed: \(error!.localizedDescription)"
                self.listener!.failureGetData( responseText )
            }
        })
        
        taskAsynch.resume()
    }
    
    func getSubString( mainString:String, startString:String , endString:String  ) -> String {
        
        var subStringReturn = "No Messages"
        
        let startS = mainString.rangeOfString(startString)
        
        let endS = mainString.rangeOfString(endString)
        
        if (startS != nil && endS != nil){
            
            let subString = mainString.substringWithRange(Range<String.Index>(start: startS!.startIndex.advancedBy(0), end: endS!.endIndex.advancedBy(0)))
            
            
            if subString.characters.count > 0 {
                
                subStringReturn = subString as String
            }
        }
        
        return subStringReturn
    }
}
