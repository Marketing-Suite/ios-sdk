//
//  EMSMobileSDK.swift
//  EMSMobileSDK
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import Foundation
import Alamofire
import UserNotifications


extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

public class EMSMobileSDK
{
    // Create Singleton Reference
    public static let `default` = EMSMobileSDK()
    
    // fields
    var backgroundSession: Alamofire.SessionManager
    public var customerID: String = ""
    public var applicationID: String = ""
    public var region: EMSRegions = EMSRegions.NorthAmericaSB
    public dynamic var prid: String = ""
    
    // Constructor/Destructor
    init() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.experian.emsmobilesdk")
        self.backgroundSession = Alamofire.SessionManager(configuration: configuration)
        print("Background Configuration Set")
    }
    
    deinit {
        print("SDK DeInit")
        //NotificationCenter.default.removeObserver(self)
    }
    
    func hexEncodedString(data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // Public Functions
    public func RegisterDeviceToken(deviceToken: Data) throws -> Void {
        var tokenString: String = ""

        tokenString = hexEncodedString(data: deviceToken)
        print("Received Token: " + tokenString)

        let urlString : String = "http://\(self.region.rawValue)/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(tokenString)"
        try
            SendEMSMessage(url: urlString, method: .post, completionHandler: { response in
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 201:
                            if let result = response.result.value {
                                print ("JSON Received: " + String(describing: response.result.value))
                                let JSON = result as! NSDictionary
                                let prid = JSON["Push_Registration_Id"] as! String
                                self.prid = prid
                                print ("PRID: " + String(describing: prid))
                            }
                        case 400:
                            throw EMSCommsError.invalidRequest
                        case 401:
                            throw EMSCommsError.notAuthenticated(userName: "")
                        case 403:
                            throw EMSCommsError.notAuthorized(userName: "")
                        default:
                            print("error with response status: \(status)")
                        }
                }
            })
        return
    }
    
    public func Initialize(customerID: String, appID: String, region: EMSRegions = EMSRegions.NorthAmericaSB){
        self.customerID = customerID
        self.applicationID = appID
        self.region = region
        print("Initialized with CustomerID: \(self.customerID), AppID: \(self.applicationID), Region: \(self.region.rawValue)")
    }
    
    func SendEMSMessage(url :String, method: HTTPMethod = .get, body: Any? = nil, completionHandler :@escaping (DataResponse<Any>) throws -> Void) throws {
        print("Calling URL: " + url)
        var encoding : ParameterEncoding
        if body != nil
        {
            encoding = body as! ParameterEncoding
        }
        else
        {
            encoding = JSONEncoding()
        }
        self.backgroundSession.request(url, method: method, encoding: encoding).validate().responseJSON {
            response in
            print ("Received: " + String(describing: response.response?.statusCode))
            try? completionHandler(response)
        }
    }
}
