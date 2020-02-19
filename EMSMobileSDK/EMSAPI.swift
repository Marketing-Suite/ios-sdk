//
//  EMSAPI.swift
//  EMSMobileSDK
//
//  Created by Mark Dennis Diwa on 08/01/2020.
//  Copyright © 2020 Experian Marketing Services. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

@objc
public class EMSAPI: NSObject {
    // fields
    public var session: URLSession
    
    override public init() {
        session = URLSession(configuration: .default)
        super.init()
    }
    
    public func subscribe(region: EMSRegions = EMSMobileSDK.default.region,
                          customerID: Int = EMSMobileSDK.default.customerID,
                          applicationID: String = EMSMobileSDK.default.applicationID,
                          deviceToken: String,
                          completionHandler: @escaping (Parameters?, HTTPURLResponse?, Error?) -> Void) {
        let url = "\(region.xts)/xts/registration/cust/\(customerID)/application/\(applicationID)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        guard let requestURL = URL(string: url) else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let dataTask = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let response = data,
            let result = try? JSONSerialization.jsonObject(with: response) as? Parameters else {
                completionHandler(nil, urlResponse as? HTTPURLResponse, error)
                return
            }
            
            completionHandler(result, urlResponse as? HTTPURLResponse, error)
        }
        
        dataTask.resume()
    }
    
    public func resubscribe(region: EMSRegions = EMSMobileSDK.default.region,
                            customerID: Int = EMSMobileSDK.default.customerID,
                            applicationID: String = EMSMobileSDK.default.applicationID,
                            deviceToken: String,
                            prid: String? = EMSMobileSDK.default.prid,
                            completionHandler: @escaping (Parameters?, HTTPURLResponse?, Error?) -> Void) {
       guard let prid = prid else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
        let url = "\(region.xts)/xts/registration/cust/\(customerID)/application/\(applicationID)/registration/\(prid)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        guard let requestURL = URL(string: url) else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let dataTask = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let response = data,
            let result = try? JSONSerialization.jsonObject(with: response) as? Parameters else {
                completionHandler(nil, urlResponse as? HTTPURLResponse, error)
                return
            }
            
            completionHandler(result, urlResponse as? HTTPURLResponse, error)
        }
        
        dataTask.resume()
    }
    
    public func unsubscribe(region: EMSRegions = EMSMobileSDK.default.region,
                            customerID: Int = EMSMobileSDK.default.customerID,
                            applicationID: String = EMSMobileSDK.default.applicationID,
                            deviceToken: String,
                            completionHandler: @escaping (String?, HTTPURLResponse?, Error?) -> Void) {
        let url = "\(region.xts)/xts/registration/cust/\(customerID)/application/\(applicationID)/token"
        
        let body: Parameters = ["DeviceToken": deviceToken]
        
        guard let requestURL = URL(string: url) else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "DELETE"
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let dataTask = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let response = data,
                let result = String(data: response, encoding: .utf8) else {
                    completionHandler(nil, urlResponse as? HTTPURLResponse, error)
                    return
                }
            
            completionHandler(result, urlResponse as? HTTPURLResponse, error)
        }
        
        dataTask.resume()
    }
    
    public func emsPost(region: EMSRegions = EMSMobileSDK.default.region,
                        customerID: Int = EMSMobileSDK.default.customerID,
                        formId: Int,
                        data: Parameters?,
                        completionHandler: @escaping (HTTPURLResponse?) -> Void) {
        let url = "\(region.ats)/ats/post.aspx?cr=\(customerID)&fm=\(formId)"
        
        guard let requestURL = URL(string: url) else {
            completionHandler(nil)
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        
        if let data = data {
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        }
        
        let dataTask = session.dataTask(with: urlRequest) { (_, urlResponse, _) in
            completionHandler(urlResponse as? HTTPURLResponse)
        }
        
        dataTask.resume()
    }
    
    public func logDeepLink(_ deepLinkUrl: String,
                            completionHandler: @escaping (HTTPURLResponse?) -> Void) {
        guard let requestURL = URL(string: deepLinkUrl) else {
            completionHandler(nil)
            return
        }
        
        let dataTask = session.downloadTask(with: URLRequest(url: requestURL)) { (_, urlResponse, _) in
            completionHandler(urlResponse as? HTTPURLResponse)
        }
        
        dataTask.resume()
    }
    
    public func logEMSOpen(url: String,
                           completionHandler: @escaping (HTTPURLResponse?) -> Void) {
        guard let requestURL = URL(string: url) else {
            completionHandler(nil)
            return
        }
        
        let dataTask = session.dataTask(with: URLRequest(url: requestURL)) { (_, urlResponse, _) in
            completionHandler(urlResponse as? HTTPURLResponse)
        }
        
        dataTask.resume()
    }
}
