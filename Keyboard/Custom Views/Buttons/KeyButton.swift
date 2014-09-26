//
//  KeyButton.swift
//  ELDeveloperKeyboard
//
//  Created by Eric Lin on 2014-07-02.
//  Copyright (c) 2014 Eric Lin. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

/**
    KeyButton is a UIButton subclass with keyboard button styling.
*/
class KeyButton: UIButton {
    
    // MARK: Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18.0)
        self.titleLabel?.textAlignment = .Center
        self.setTitleColor(UIColor(white: 50.0/255, alpha: 1.0), forState: UIControlState.Normal)
        self.titleLabel?.sizeToFit()
        
        var whiteImage = imageFromColor(UIColor.whiteColor())
        self.setBackgroundImage(whiteImage, forState: .Normal)
        
        var grayImage = imageFromColor(UIColor.grayColor())
        self.setBackgroundImage(grayImage, forState: .Selected)
        
        var im = UIImage()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.contentVerticalAlignment = .Center
        self.contentHorizontalAlignment = .Center
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
    }
    
    func imageFromColor(color: UIColor) -> UIImage {
        var rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size);
        var context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}