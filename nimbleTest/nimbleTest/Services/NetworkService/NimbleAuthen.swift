//
//  NimbleAuthen.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Class handle nimble authentication process
class NimbleAuthen {
    /// Global instance for authentication
    static let sharedInstance = NimbleAuthen()
    // MARK: - Properties
    private var username = "carlos@nimbl3.com" // known username
    private var password = "antikera" // known password
    
    private struct Token {
        var accessToken: String
        var type: String
    }
    private var currentToken: Token?
    
    // MARK: - Methods
    func getAuthorizationToken() -> String {
        guard let token = currentToken else {
            return ""
        }
        return "\(token.type) \(token.accessToken)"
    }
    
    func refreshToken(onComplete: @escaping (_ success: Bool) -> Void) {
        let params = [NimbleAuthJsonApiKey.username: username
            , NimbleAuthJsonApiKey.password: password
            , NimbleAuthJsonApiKey.grantType: GrantType.password]
        Alamofire.request(AuthenUrl.base + AuthenUrl.Path.oauthToken, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200...200)
            .responseJSON { (response) in
                guard response.result.isSuccess else { // or response.result.error == nil
                    // got an error in getting the data, need to handle it
                    print("error calling POST on \(AuthenUrl.Path.oauthToken)")
                    print(response.result.error!)
                    onComplete(false)
                    return
                }
                
                guard let value = response.result.value else {
                    print("error no data received from service")
                    //onCompletionSuccess(success: false, errorMessage: DefaultText.connectionErrorMessage)
                    onComplete(false)
                    return
                }
                
                let jsonData = JSON(value)
                // TODO: Validate json
                let token = jsonData[NimbleAuthJsonApiKey.accessToken].stringValue
                let type = jsonData[NimbleAuthJsonApiKey.tokenType].stringValue
                self.currentToken = Token(accessToken: token, type: type)
                print("refreshed token: \(type) \(token)")
                onComplete(true)
        }
    }
}

// MARK: - Attributes Declaration
fileprivate struct AuthenUrl {
    static let base = "https://nimbl3-survey-api.herokuapp.com"
    struct Path {
        static let oauthToken = "/oauth/token"
    }
}

fileprivate struct NimbleAuthJsonApiKey {
    static let username = "username"
    static let password = "password"
    static let grantType = "grant_type"
    static let accessToken = "access_token"
    static let tokenType = "token_type"
}

fileprivate struct GrantType {
    static let password = "password"
}
