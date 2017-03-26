//
//  NetworkError.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation

/// Simple network error status for this project.
///
/// - authorizationFailed: Code 401, use for refresh token.
/// - jsonParsingFailed: Response serialization error occurred.
/// - resultFailed: No result return from response.
enum NetworkError: Error {
    case authorizationFailed
    case jsonParsingFailed
    case noResultFailed
}
