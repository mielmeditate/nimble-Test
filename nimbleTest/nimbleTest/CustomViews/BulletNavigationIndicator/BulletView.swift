//
//  BulletView.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import UIKit

class BulletView: UIView {
    var currentPage: Bool = false {
        didSet {
            self.layoutSubviews()
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2.0
        if currentPage {
            setViewForCurrentPage()
        }else {
            setViewForNotCurrentPage()
        }
    }
    
    func setViewForCurrentPage() {
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 0
    }
    
    func setViewForNotCurrentPage() {
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.white.cgColor
    }
}
