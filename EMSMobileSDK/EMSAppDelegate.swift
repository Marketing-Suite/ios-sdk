//
//  EMSAppDelegate.swift
//  Pods
//
//  Created by Paul Ballard on 1/16/17.
//
//

import Foundation

public protocol EMSAppDelegate
{
    func onTokenRefresh(deviceToken: Data)
}
