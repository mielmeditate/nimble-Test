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
}

// MARK: - Attributes Declaration
typealias NetworkRequestCall = ((@escaping NetworkResponseCallback) -> Void)
typealias NetworkResponseCallback = ((_ value: Any?,_ error: NetworkError?) -> Void)

struct ResponseCode {
    static let unauthorized = 401
}
