//
//  NavigationController.swift
//  MelbourneWay
//
//  Created by Chandan Singh on 28/03/2016.
//  Copyright © 2016 RMIT. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController,UIViewControllerTransitioningDelegate{
    
    override func viewDidLoad() {
        
        //Sets the color of navigation bar to orange
        self.navigationBar.barTintColor = UIColor.orangeColor()
        //Sets the text inside the bar to white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
}
