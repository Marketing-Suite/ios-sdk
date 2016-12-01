//
//  PostDeviceRegistration.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 9/26/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PostDeviceListener: NSObjectProtocol

public protocol PostDeviceListener: NSObjectProtocol {
    func successPostDevice(response: String)
    func failurePostDevice(error: String)
}

// MARK: - PostDeviceRegistration: NSObject

public class PostDeviceRegistration: NSObject {
    
    // Listener passed in by the owning object
    public var listener : PostDeviceListener?
    
    public override init() {}
    // Assign listener implementing events interface that will receive the events (passed in by the owner)
    public func setPostDeviceListener( listener: PostDeviceListener) {
        self.listener = listener
    }
    
    public func registerDevice(){
    // Check Network Reachable
        if CheckNetwork.isConnectedToNetwork() == true {
            self.getRegistration()
        } else {
            //self.errorAlert("Internet connection FAILED")
        }
    }
    
    
    public func getRegistration () -> Void{
        
        // TODO:Build URL
        let emsPush:EMSPush = EMSPush();
        let endPoint:String = emsPush.getEndPoint()
        let customerID:String = emsPush.getCustomerID()
        let applicationID:String = emsPush.getApplicationID()
        let deviceToken:String = emsPush.getToken()
        
        // Build URL 
        // http://cs.sbox.eccmp.com/xts/registration/cust/100/application/ce64adbd-8082-44be-b74b-f2baa84c242a/token/
        let url:String = "http://" + endPoint + "/xts/registration/cust/" + customerID + "/application/" + applicationID + "/token/\(deviceToken)";

        
        let requestURL = NSURL(string: url)
        let urlRequest = NSMutableURLRequest(URL: requestURL!)
        urlRequest.HTTPMethod = "POST"
        //urlRequest.setValue(deviceToken, forUndefinedKey: "DeviceToken")
        
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
                    
                    print("URL POST Session Task Succeeded: HTTP \(statusCode)")
                    
                    let responseDictionary:NSDictionary =
                        (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    
                    if let prid:String = responseDictionary["Push_Registration_Id"] as? String
                    {
                        emsPush.setPushRegistrationID(prid)
                        print (prid)
                        
                        let responseString =  "\(response!)"
                        
                        print("<HEADER: \(responseString)>, <BODY: \(responseDictionary)> <prid: \(prid)>")
                        
                        let responseText = "<HEADER: \(responseString)>, <BODY: \(responseDictionary)> <prid: \(prid)>"
                        
                        print("URL POST Session Task Succeeded: HTTP \(statusCode)")
                        print(responseDictionary)
                        
                        self.listener!.successPostDevice(responseText)
                    }
                }
                else
                {
                    let responseText = "URL POST Unexpected Status: HTTP \(statusCode)"
                    
                    self.listener!.failurePostDevice(responseText)
                }
            }
            else {
                // Failure
                let responseText = "URL POST Session Task Failed: \(error!.localizedDescription)"
                
                self.listener!.failurePostDevice(responseText)
            }
        })
        
        taskAsynch.resume()
    }
}
