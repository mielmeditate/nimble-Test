//
//  SurveyDataModel.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SurveyListRow {
    var id: String
    var title: String
    var description: String
    var coverImageUrl: String
    var question: JSON
}
