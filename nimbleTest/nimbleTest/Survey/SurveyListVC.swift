//
//  SurveyListVC.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import UIKit
import Kingfisher

class SurveyListVC: UIViewController {
    // MARK: - Layout Properties
    @IBOutlet fileprivate weak var cv_survey: UICollectionView!
    @IBOutlet private weak var btn_takeSurvey: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    fileprivate var bulletIndicator: BulletCVC?
    
    // MARK: - Properties
    private let surveyListModel = SurveyListModel()
    fileprivate var surveyListData = [SurveyListRow]()
    private var refreshing = false
    
    fileprivate struct Storyboard {
        static let surveyCell = "SurveyCell"
        static let segueTakeSurvey = "TakeSurvey"
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Initial fetching
        refreshing = true
        activityIndicatorView.startAnimating()
        fetchNextPageSurvey()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btn_takeSurvey.layer.cornerRadius = btn_takeSurvey.frame.height / 2.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Storyboard.segueTakeSurvey {
            if surveyListData.count == 0 {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bulletCVC = segue.destination as? BulletCVC {
            // Setup bullet
            bulletCVC.radius = 8
            bulletCVC.spaceExpected = 10
            bulletCVC.resetBullet(numberOfBullets: surveyListData.count)
            bulletIndicator = bulletCVC
        }else if segue.identifier == Storyboard.segueTakeSurvey {
            guard surveyListData.count > 0 else {
                return
            }
            let page = Int((cv_survey.contentOffset.y + cv_survey.frame.height / 2.0) / cv_survey.frame.height)
            if page >= 0 && page < surveyListData.count {
                let selectedSurveyData = surveyListData[page]
                let takeSurveyVC = segue.destination as! TakeSurveyVC
                takeSurveyVC.setData(title: selectedSurveyData.title, questionJson: selectedSurveyData.question)
            }
        }
    }
    
    // MARK: - Setup UI
    private func setUpUI() {
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        rightBtn.addTarget(self, action: #selector(clickMenu(_:)), for: .touchUpInside)
        rightBtn.setImage(UIImage(named: "menu_burger"), for: .normal)
        
        let barBtnRight = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = barBtnRight
        
        let transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorView.transform = transform
    }
    
    // MARK: - IBActions
    @IBAction private func clickTakeSurvey(_ sender: UIButton) {
        // fetchNextPageSurvey() // Testing purpose
    }
    
    @IBAction func clickRefresh(_ sender: UIBarButtonItem) {
        refreshSurveys()
    }
    
    // MARK: - Custom Actions
    @objc private func clickMenu(_ sender: UIButton) {
        print("Click menu: \(sender)")
        // fetchNextPageSurvey() // Testing purpose
    }
    
    // MARK: - Methods
    private func appendSurvey(surveyListArray: [SurveyListRow]) {
        guard surveyListArray.count >= 0 else {
            return
        }
        let lastIndex = surveyListData.count
        surveyListData.append(contentsOf: surveyListArray)
        var addIndexes: [IndexPath] = []
        for newSurveyIndex in 0..<surveyListArray.count {
            let bulletIndexPath = IndexPath(item: lastIndex + newSurveyIndex, section: 0)
            addIndexes.append(bulletIndexPath)
        }
        cv_survey.insertItems(at: addIndexes)
        bulletIndicator?.addBullets(addingTotal: surveyListArray.count)
        print("Current total surveys = \(surveyListData.count)")
    }
    
    fileprivate func fetchNextPageSurvey() {
        guard !surveyListModel.isEndOfData() else {
            print("End of survey data")
            return
        }
        surveyListModel.getSurveyList {[weak self] (surveyListArray, error) in
            guard let strongSelf = self else { return }
            if strongSelf.activityIndicatorView.isAnimating {
                strongSelf.activityIndicatorView.stopAnimating()
            }
            strongSelf.refreshing = false
            guard error == nil else {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .authorizationFailed:
                        print("Handle authorize failed")
                    case .jsonParsingFailed:
                        print("Handle parsing failed")
                    case .noResultFailed:
                        print("Handle no result failed")
                    }
                }else {
                    // Handle another error
                }
                return
            }
            if let surveyListArray = surveyListArray {
                strongSelf.appendSurvey(surveyListArray: surveyListArray)
            }
        }
    }
    
    private func refreshSurveys() {
        guard !refreshing else {
            return
        }
        refreshing = true
        NetworkManager.cancelAllNetworkTask()
        surveyListData = []
        surveyListModel.refreshData()
        cv_survey.reloadData()
        bulletIndicator?.resetBullet(numberOfBullets: 0)
        
        // Re-fetch data again
        activityIndicatorView.startAnimating()
        fetchNextPageSurvey()
    }
}

// MARK: - UICollectionViewDataSource
extension SurveyListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveyListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.surveyCell, for: indexPath) as! SurveyCell
        
        let surveyRowData = surveyListData[indexPath.row]
        let url = URL(string: surveyRowData.coverImageUrl+"l") // Add 'l' for large image
        cell.imgv_cover.kf.setImage(with: url)
        cell.lb_title.text = surveyRowData.title
        cell.lb_description.text = surveyRowData.description
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SurveyListVC: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Change bullet position
        let page = scrollView.contentOffset.y / scrollView.frame.height
        bulletIndicator?.changeCurrentBulletTo(index: Int(page))
        
        // End of data, Try to fetch next page
        if Int(page) == surveyListData.count - 1 {
            fetchNextPageSurvey()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SurveyListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cv_survey.frame.size
    }
}
