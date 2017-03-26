//
//  SurveyListModel.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation
import SwiftyJSON

class SurveyListModel {
    // MARK: - Properties
    private var curretPage = 1
    private var per_page = 10
    private var downloading = false // For downloading only one at a time
    private var endOfData = false
    
    // MARK: - Methods
    func getSurveyList(onComplete: @escaping (_ surveyList: [SurveyListRow]?, _ error: Error?) -> Void) {
        print("Get survey list, page = \(curretPage), per_page = \(per_page)")
        guard !downloading else {
            print("Still downloading in page = \(curretPage), per_page = \(per_page)")
            return
        }
        downloading = true
        let nimbleService = NimbleService()
        let surveysCall = nimbleService.getSurveyList(page: curretPage, per_page: per_page)
        NetworkManager.requestNimbleService(call: surveysCall) { [weak self]
            (value, error) in
            guard let strongSelf = self else { return }
            strongSelf.downloading = false
            
            guard error == nil else {
                onComplete(nil, error) // Forward error back
                return
            }
            
            if let value = value {
                if value is NSNull {
                    print("value is null class")
                    strongSelf.endOfData = true
                    onComplete(nil, nil) // No more data
                }else {
                    let jsonData = JSON(value)
                    // TODO: Validate json
                    let surveyJsonArray = jsonData.arrayValue
                    // If empty array then end of data
                    if surveyJsonArray.count == 0 {
                        strongSelf.endOfData = true
                        onComplete(nil, nil) // No more data
                        return
                    }
                    var surveyListModelArray = [SurveyListRow]()
                    for eachJson in surveyJsonArray {
                        let id = eachJson[JsonApiKey.Survey.id].stringValue
                        let title = eachJson[JsonApiKey.Survey.title].stringValue
                        let desc = eachJson[JsonApiKey.Survey.description].stringValue
                        let coverImageUrl = eachJson[JsonApiKey.Survey.coverImageUrl].stringValue
                        let questions = eachJson[JsonApiKey.Survey.questions]
                        
                        let surveyListModel = SurveyListRow(id: id, title: title, description: desc, coverImageUrl: coverImageUrl, question: questions)
                        surveyListModelArray.append(surveyListModel)
                    }
                    // Append current page
                    strongSelf.curretPage += 1
                    onComplete(surveyListModelArray, nil)
                }
            }else {
                onComplete(nil, nil)
            }
        }
    }
    
    /// Get end of data status
    ///
    /// - Returns: Boolean indicate end of data
    func isEndOfData() -> Bool {
        return endOfData
    }
    
    /// Reset data properties eg., current page, end of file
    func refreshData() {
        curretPage = 1
        endOfData = false
        downloading = false
    }
}
