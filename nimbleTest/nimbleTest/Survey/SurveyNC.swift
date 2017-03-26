//
//  SurveyNC.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import UIKit

class SurveyNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar configuration
        self.navigationBar.barTintColor = UIColor(netHex: 0x121C37)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
