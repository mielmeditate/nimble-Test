//
//  TakeSurveyVC.swift
//  nimbleTest
//
//  Created by Miel on 3/26/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Simple Take Survey implementation, so mess all code in here
class TakeSurveyVC: UIViewController {
    @IBOutlet weak var lb_surveyTitle: UILabel!
    @IBOutlet weak var tv_question: UITableView!
    
    var surveyTitle = ""
    var questionDataArray = [SurveyQuestionListRow]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(title: String, questionJson: JSON) {
        self.surveyTitle = title
        let questionArray = questionJson.arrayValue
        var surveyQuestionArray = [SurveyQuestionListRow]()
        for eachJson in questionArray {
            let text = eachJson[JsonApiKey.Survey.Question.text].stringValue
            let surveyQuestionListRow = SurveyQuestionListRow(text: text)
            surveyQuestionArray.append(surveyQuestionListRow)
        }
        questionDataArray = surveyQuestionArray
    }
    
    func setUpUI() {
        lb_surveyTitle.text = surveyTitle
    }
}

extension TakeSurveyVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyQuestionCell", for: indexPath) as! SurveyQuestionTVCell
        let surveyQuestionRow = questionDataArray[indexPath.row]
        cell.lb_questionText.text = surveyQuestionRow.text
        return cell
    }
}

extension TakeSurveyVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

struct SurveyQuestionListRow {
    var text: String
}

