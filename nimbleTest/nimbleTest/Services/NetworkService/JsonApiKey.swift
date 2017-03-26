//
//  JsonApiKey.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation

struct JsonApiKey {
    struct Survey {
        // Request
        static let page = "page"
        static let per_page = "per_page"
        
        // Response
        static let id = "id"
        static let title = "title"
        static let description = "description"
        static let coverImageUrl = "cover_image_url"
        static let questions = "questions"
        
        struct Question {
            static let text = "text"
        }
    }
}
