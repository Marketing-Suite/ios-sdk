//
//  GetEnvironment.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 9/26/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import Foundation
import UIKit

// MARK: - GetEMSEnvironmentListener: NSObjectProtocol

public protocol GetEMSEnvironmentListener: NSObjectProtocol {
    func successGetEnvironment(json: NSDictionary)
    func failureGetEnvironment(jsonError: String)
}

// MARK: - GetEMSEnvironment:NSObject

public class GetEMSEnvironment:NSObject  {
    
    // Listener passed in by the owning object
    public var listener : GetEMSEnvironmentListener?
    
    public override init() {}
    // Assign listener implementing events interface that will receive the events (passed in by the owner)
    public func setGetEnvironmentListener( listener: GetEMSEnvironmentListener) {
        self.listener = listener
    }
    
    public func getJson() {
        
        let requestURL: NSURL = NSURL(string: Constants.CONFIGURL)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let taskAsynch = session.dataTaskWithRequest(urlRequest, completionHandler:{
            data, response, err -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    self.listener!.successGetEnvironment(json as! NSDictionary)
                    
                    //self.parseEnvironmentValues( json as! NSDictionary )
                    
                }catch {
                    self.listener!.failureGetEnvironment("Error with Json: \(error)" )
                    //self.errorAlert("Error with Json: \(error)")
                }
            }
            else{
                self.listener!.failureGetEnvironment("Status Error: \(statusCode)" )
               // self.errorAlert("Status Error: \(statusCode)")
            }
        })
        
        taskAsynch.resume()
    }
    
    public func getJsonFile(){
        
        if let path = NSBundle.mainBundle().pathForResource("environments", ofType: "json") {
            
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        
                       // if let json : NSArray = //jsonResult["environments"] as? NSArray {
                            
                            self.listener!.successGetEnvironment(jsonResult )
                       // }
                    }
                }
                catch {
                    // TODO: Pass error back to caller
                    
                    self.listener!.failureGetEnvironment("Error while reading: \(error)" )
                    //print("Error while parsing: \(error)")
                }
            }
        }
    }
}
