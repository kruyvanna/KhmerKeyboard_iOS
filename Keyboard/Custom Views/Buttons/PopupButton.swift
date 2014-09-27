//
//  PopupButton.swift
//  KhmerKeyboard
//
//  Created by Vanna Kruy on 9/27/14.
//  Copyright (c) 2014 Eric Lin. All rights reserved.
//

import Foundation
import UIKit

class PopupButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var image = UIImage(named: "popup")
        self.setBackgroundImage(image, forState: .Normal);
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 7
        self.layer.shadowOffset = CGSizeMake(-2, 0)
        self.layer.masksToBounds = false
        self.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}