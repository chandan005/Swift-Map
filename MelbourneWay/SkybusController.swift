//
//  SkybusController.swift
//  MelbourneWay
//
//  Created by Chandan Singh on 5/04/2016.
//  Copyright © 2016 RMIT. All rights reserved.
//

import UIKit


class SkybusController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        self.tabBarController?.title = "Skybus"
    }
    
}
