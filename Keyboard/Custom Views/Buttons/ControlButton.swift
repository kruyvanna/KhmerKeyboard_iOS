//
//  ControlButton.swift
//  ELDeveloperKeyboard
//
//  Created by Vanna Kruy on 9/25/14.
//  Copyright (c) 2014 KRUY VANNA. All rights reserved.
//

import Foundation
import UIKit

class ControlButton: KeyButton {
    override init(frame: CGRect){
        super.init(frame: frame)
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        let gradientColors: [AnyObject] = [UIColor(red: 172/255, green: 179/255, blue: 190/255, alpha: 1.0).CGColor, UIColor(red: 172/255, green: 179/255, blue: 190/255, alpha: 1.0).CGColor]
        gradient.colors = gradientColors // Declaration broken into two lines to prevent 'unable to bridge to Objective C' error.
        self.setBackgroundImage(gradient.UIImageFromCALayer(), forState: .Normal)
        
        let selectedGradient = CAGradientLayer()
        selectedGradient.frame = self.bounds
        let selectedGradientColors: [AnyObject] = [UIColor(red: 91.0/255, green: 95.0/255, blue: 101.0/255, alpha: 1.0).CGColor, UIColor(red: 91.0/255, green: 95.0/255, blue: 101.0/255, alpha: 1.0).CGColor]
        selectedGradient.colors = selectedGradientColors // Declaration broken into two lines to prevent 'unable to bridge to Objective C' error.
        self.setBackgroundImage(selectedGradient.UIImageFromCALayer(), forState: .Selected)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}