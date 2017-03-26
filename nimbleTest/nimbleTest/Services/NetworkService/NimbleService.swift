//
//  NimbleService.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation
import Alamofire

/// Class contain all of nimble services
class NimbleService {
    
    /// Get alamofire HTTPHeaders for services
    ///
    /// - Returns: Authorization HTTPHeaders
    func generateRequestHeader() -> HTTPHeaders {
        return ["Authorization": NimbleAuthen.sharedInstance.getAuthorizationToken()]
    }
    
    /// Get surveys api
    ///
    /// - Parameters:
    ///   - page: Page to fetch
    ///   - per_page: Number of survey per page
    /// - Returns: Closure that handle call service
    func getSurveyList(page: Int, per_page: Int) -> NetworkRequestCall {
        let call = { (onComplete: @escaping NetworkResponseCallback) in
            let params = [JsonApiKey.Survey.page: page, JsonApiKey.Survey.per_page: per_page]
            Alamofire.request(NimbleApi.base + NimbleApi.Path.surveys, method: .get, parameters: params, encoding: URLEncoding.default, headers: self.generateRequestHeader())
                .responseJSON(completionHandler: { (response) in
                    guard response.response?.statusCode != ResponseCode.unauthorized else {
                        onComplete(nil, NetworkError.authorizationFailed)
                        return
                    }
                    
                    guard response.result.isSuccess else {
                        // got an error in getting the data, need to handle it
                        print("error calling GET on \(NimbleApi.Path.surveys)")
                        print(response.result.error!)
                        onComplete(nil, NetworkError.noResultFailed)
                        return
                    }
                    
                    onComplete(response.result.value, nil)
                })
        }
        return call 
    }
}

// MARK: - Attributes Declaration
fileprivate struct NimbleApi {
    static let base = "https://nimbl3-survey-api.herokuapp.com"
    
    struct Path {
        static let surveys = "/surveys.json"
    }
}
