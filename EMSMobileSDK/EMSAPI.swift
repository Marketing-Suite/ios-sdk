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
    
    public static func subscribe(region: EMSRegions = EMSMobileSDK.default.region,
                                 customerID: Int = EMSMobileSDK.default.customerID,
                                 applicationID: String = EMSMobileSDK.default.applicationID,
                                 deviceToken: String,
                                 completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let url = "\(region.xts))/xts/registration/cust/\(customerID)/application/\(applicationID)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        let request = EMSMobileSDK.default.backgroundSession.request(url,
                                                                     method: .post,
                                                                     parameters: body,
                                                                     encoding: JSONEncoding.default)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public static func resubscribe(region: EMSRegions = EMSMobileSDK.default.region,
                                   customerID: Int = EMSMobileSDK.default.customerID,
                                   applicationID: String = EMSMobileSDK.default.applicationID,
                                   deviceToken: String,
                                   prid: String? = EMSMobileSDK.default.prid,
                                   completionHandler: @escaping (DataResponse<Any>) -> Void) {
        
        let url = "\(region.xts))/xts/registration/cust/\(customerID)/application/\(applicationID)/registration/\(prid ?? "")/token"
        
        guard prid != nil else {
            let dataResponse = DataResponse<Any>(request: nil,
                                                 response: nil,
                                                 data: nil,
                                                 result: .failure(AFError.invalidURL(url: url)))
            completionHandler(dataResponse)
            return
        }
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        let request = EMSMobileSDK.default.backgroundSession.request(url,
                                                                     method: .put,
                                                                     parameters: body,
                                                                     encoding: JSONEncoding.default)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public static func unsubscribe(region: EMSRegions = EMSMobileSDK.default.region,
                                   customerID: Int = EMSMobileSDK.default.customerID,
                                   applicationID: String = EMSMobileSDK.default.applicationID,
                                   deviceToken: String,
                                   completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let url = "\(region.xts))/xts/registration/cust/\(customerID)/application/\(applicationID)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        let request = EMSMobileSDK.default.backgroundSession.request(url,
                                                                     method: .delete,
                                                                     parameters: body,
                                                                     encoding: JSONEncoding.default)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public static func emsPost(region: EMSRegions = EMSMobileSDK.default.region,
                               customerID: Int = EMSMobileSDK.default.customerID,
                               formId: Int,
                               data: Parameters?,
                               completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let urlString: String = "\(region.ats))/ats/post.aspx?cr=\(customerID)&fm=\(formId)"
        let request = EMSMobileSDK.default.backgroundSession.request(urlString,
                                                                     method: .post,
                                                                     parameters: data,
                                                                     encoding: URLEncoding.default)
        request.validate().responseJSON(completionHandler: completionHandler)
    }
    
    public static func logDeepLink(_ deepLinkUrl: String,
                                   completionHandler: @escaping (DownloadResponse<String>) -> Void) {
        let request = EMSMobileSDK.default.backgroundSession.download(deepLinkUrl)
        request.validate().responseString(completionHandler: completionHandler)
    }
    
    public static func logEMSOpen(url: String,
                                  completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let request = EMSMobileSDK.default.backgroundSession.request(url,
                                                                     method: .get,
                                                                     parameters: nil,
                                                                     encoding: JSONEncoding.default)
        
        request.validate().responseJSON(completionHandler: completionHandler)
    }
}
