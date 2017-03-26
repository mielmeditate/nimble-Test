//
//  BulletCVC.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import UIKit

class BulletCVC: UICollectionViewController {
    // MARK: - Properties
    
    // Public API
    /// Radius of bullet, using min(radius, view width)
    var radius: CGFloat = 15 { didSet { updateUI () } }
    /// Expected space between bullets, it will calculate total showing bullets with closest space possible
    var spaceExpected: CGFloat = 20 { didSet { updateUI () } }
    
    /// Total bullets
    fileprivate var numberOfBullets = 0
    /// Current bullet index
    fileprivate var currentBullet = 0
    private let bulletIdentifier = "BulletCell"
    
    // Compute Properties
    fileprivate var bulletWidth: CGFloat {
        let diameter = CGFloat(2 * radius)
        if self.collectionView!.frame.width > diameter {
            return diameter
        }else {
            return self.collectionView!.frame.width
        }
    }
    
    fileprivate var totalBulletShowing: Int {
        var numberOfShowing = (self.collectionView!.frame.height + spaceExpected) / (bulletWidth + spaceExpected)
        numberOfShowing = round(numberOfShowing)
        return Int(numberOfShowing)
    }
    
    fileprivate var spaceBetweenBullet: CGFloat {
        return (self.collectionView!.frame.height - (bulletWidth * CGFloat(totalBulletShowing))) / CGFloat(totalBulletShowing - 1)
    }
    
    fileprivate var bulletOffset: CGFloat {
        return bulletWidth + spaceBetweenBullet
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    // Public API Methods
    
    /// Append bullets to current bullets list
    ///
    /// - Parameter addingTotal: Total bullets with positive integer
    func addBullets(addingTotal: Int) {
        guard addingTotal >= 0 else {
            return
        }
        let lastIndex = numberOfBullets
        numberOfBullets += addingTotal
        var addIndexes: [IndexPath] = []
        for bulletIndex in 0..<addingTotal {
            let bulletIndexPath = IndexPath(item: lastIndex + bulletIndex, section: 0)
            addIndexes.append(bulletIndexPath)
        }
        self.collectionView!.insertItems(at: addIndexes)
    }
    
    
    /// Reassign total number of bullet
    ///
    /// - Parameter numberOfBullets: Total bullets with positive integer
    func resetBullet(numberOfBullets: Int) {
        guard numberOfBullets >= 0 else {
            return
        }
        currentBullet = 0
        self.numberOfBullets = numberOfBullets
        updateUI()
    }
    
    /// Change current bullet to next
    func moveToNextBullet() {
        if currentBullet < numberOfBullets - 1 {
            changeCurrentBulletTo(index: currentBullet + 1)
        }
    }
    
    /// Change current bullet to previous
    func moveToPreviousBullet() {
        if currentBullet > 0 {
            changeCurrentBulletTo(index: currentBullet - 1)
        }
    }
    
    /// Change current bullet index
    ///
    /// - Parameter index: New current index
    func changeCurrentBulletTo(index: Int) {
        guard index >= 0 && index < numberOfBullets && index != currentBullet else {
            //print("Overflow or index not change")
            return
        }
        let lastBullet = currentBullet
        let nextOffset = calculateCurrentBulletOffset(currentBullet: index)
        self.collectionView!.setContentOffset(CGPoint(x: 0, y: nextOffset), animated: true)
        currentBullet = index
        
        self.collectionView!.reloadItems(at: [IndexPath(item: lastBullet, section: 0), IndexPath(item: index, section: 0)])
    }
    
    // Private Methods
    private func calculateCurrentBulletOffset(currentBullet: Int) -> CGFloat {
        // Floor the half of total number of bullet showing
        let topOffset: CGFloat = CGFloat(floor(Double(totalBulletShowing) / 2.0)) * bulletOffset
        // Calculate new offset
        var newBulletOffset: CGFloat = (CGFloat(currentBullet) * bulletOffset) - topOffset
        // Check the offset not overflow
        newBulletOffset = min(newBulletOffset, self.collectionView!.contentSize.height - self.collectionView!.frame.height)
        return max(0, newBulletOffset)
    }
    
    private func updateUI() {
        self.collectionView?.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfBullets
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bulletIdentifier, for: indexPath) as! BulletCVCell
        let view: BulletView = cell.view_bullet
        if indexPath.row == currentBullet {
            view.currentPage = true
        }else {
            view.currentPage = false
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BulletCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = bulletWidth
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenBullet
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let remainHorizontalSpace = self.collectionView!.frame.width - bulletWidth
        let horizontalPadding = remainHorizontalSpace > 0 ? remainHorizontalSpace / 2.0 : 0
        let verticalPadding = calculateVerticalInset()
        return UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    private func calculateVerticalInset() -> CGFloat {
        let spaceForInset = self.collectionView!.frame.height - ((CGFloat(numberOfBullets) * bulletOffset) - spaceBetweenBullet)
        return spaceForInset > 0 ? spaceForInset / 2.0 : 0
    }
}
