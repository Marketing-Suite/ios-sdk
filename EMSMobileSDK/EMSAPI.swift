//
//  EMSAPI.swift
//  EMSMobileSDK
//
//  Created by Mark Dennis Diwa on 08/01/2020.
//  Copyright © 2020 Experian Marketing Services. All rights reserved.
//

import Alamofire
import Foundation

@objc
public class EMSAPI: NSObject {
    // fields
    public var session: Alamofire.SessionManager
    
    override public init() {
        session = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        super.init()
    }
    
    public func subscribe(region: EMSRegions = EMSMobileSDK.default.region,
                          customerID: Int = EMSMobileSDK.default.customerID,
                          applicationID: String = EMSMobileSDK.default.applicationID,
                          deviceToken: String,
                          completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let url = "\(region.xts)/xts/registration/cust/\(customerID)/application/\(applicationID)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        let request = session.request(url,
                                      method: .post,
                                      parameters: body)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public func resubscribe(region: EMSRegions = EMSMobileSDK.default.region,
                            customerID: Int = EMSMobileSDK.default.customerID,
                            applicationID: String = EMSMobileSDK.default.applicationID,
                            deviceToken: String,
                            prid: String? = EMSMobileSDK.default.prid,
                            completionHandler: @escaping (DataResponse<Any>) -> Void) {
        
        let url = "\(region.xts)/xts/registration/cust/\(customerID)/application/\(applicationID)/registration/\(prid ?? "")/token"
        
        guard prid != nil else {
            let dataResponse = DataResponse<Any>(request: nil,
                                                 response: nil,
                                                 data: nil,
                                                 result: .failure(AFError.invalidURL(url: url)))
            completionHandler(dataResponse)
            return
        }
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        let request = session.request(url,
                                      method: .put,
                                      parameters: body)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public func unsubscribe(region: EMSRegions = EMSMobileSDK.default.region,
                            customerID: Int = EMSMobileSDK.default.customerID,
                            applicationID: String = EMSMobileSDK.default.applicationID,
                            deviceToken: String,
                            completionHandler: @escaping (DataResponse<String>) -> Void) {
        let url = "\(region.xts)/xts/registration/cust/\(customerID)/application/\(applicationID)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        let request = session.request(url,
                                      method: .delete,
                                      parameters: body,
                                      encoding: JSONEncoding.default)
        request.validate().responseString(completionHandler: completionHandler)
    }
    
    public func emsPost(region: EMSRegions = EMSMobileSDK.default.region,
                        customerID: Int = EMSMobileSDK.default.customerID,
                        formId: Int,
                        data: Parameters?,
                        completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let urlString: String = "\(region.ats)/ats/post.aspx?cr=\(customerID)&fm=\(formId)"
        let request = session.request(urlString,
                                      method: .post,
                                      parameters: data)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public func logDeepLink(_ deepLinkUrl: String,
                            completionHandler: @escaping (DownloadResponse<String>) -> Void) {
        let request = session.download(deepLinkUrl)
        request.validate().responseString(completionHandler: completionHandler)
    }
    
    public func logEMSOpen(url: String,
                           completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let request = session.request(url,
                                      method: .get,
                                      parameters: nil)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
}
