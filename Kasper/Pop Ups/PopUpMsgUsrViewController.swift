//
//  PopUpMsgUsrViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/12/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class PopUpMsgUsrViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Transparent Background
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }

    // GO: Back
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.view.removeFromSuperview()
    }

}
