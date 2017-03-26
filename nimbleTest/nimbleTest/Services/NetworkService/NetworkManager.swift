//
//  NetworkManager.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    /// Handle request with 2 hop authorization check, try refresh token one time.
    static func requestNimbleService(call: @escaping NetworkRequestCall, onComplete: @escaping NetworkResponseCallback) {
        call{(value, error) in
            if let error = error {
                // For authorized failed first time, try refresh token and call service again
                if error == NetworkError.authorizationFailed {
                    NimbleAuthen.sharedInstance.refreshToken(onComplete: { (success) in
                        if success {
                            // Call service again
                            call({ (value2, error2) in
                                onComplete(value2, error2)
                            })
                        }else {
                            // Refresh token failed
                            onComplete(value, error)
                        }
                    })
                }else {
                    // Forward response error back
                    onComplete(value, error)
                }
            }else {
                // Forward response back
                onComplete(value, error)
            }
        }
    }
    
    static func cancelAllNetworkTask() {
        let session = Alamofire.SessionManager.default.session
        session.getAllTasks { (tasks) in
            tasks.forEach { $0.cancel() }
        }
    }
    
    // Just do some research for request retrier, not working for now
    private static let lock = NSLock()
    private static var requestsToRetry: [(NetworkRequestCall, NetworkResponseCallback)] = []
    private static var isRefreshing = false
    
    static func requestRetrier(requestCall: @escaping NetworkRequestCall, responseCallback: @escaping NetworkResponseCallback) {
        lock.lock() ; defer { lock.unlock() }
        print("Start request retrier")
        requestsToRetry.append((requestCall, responseCallback))
        if !isRefreshing && requestsToRetry.count > 0 {
            isRefreshing = true
            NimbleAuthen.sharedInstance.refreshToken(onComplete: { (success) in
                self.lock.lock() ; defer { self.lock.unlock() }
                
                if success {
                    // Call services again
                    self.requestsToRetry.forEach{ (request: (NetworkRequestCall, NetworkResponseCallback)) in
                        let (retryRequest, onComplete) = request
                        retryRequest{ (value2, error2) in
                            onComplete(value2, error2)
                        }
                    }
                }else {
                    // Refresh token failed, forward authorization failed message
                    self.requestsToRetry.forEach{ (request: (NetworkRequestCall, NetworkResponseCallback)) in
                        let (_, onComplete) = request
                        onComplete(nil, .authorizationFailed)
                    }
                }
                self.requestsToRetry.removeAll()
                isRefreshing = false
                print("Finish request retrier")
            })
        }
    }
}

// MARK: - Attributes Declaration
typealias NetworkRequestCall = ((@escaping NetworkResponseCallback) -> Void)
typealias NetworkResponseCallback = ((_ value: Any?,_ error: NetworkError?) -> Void)

struct ResponseCode {
    static let unauthorized = 401
}
