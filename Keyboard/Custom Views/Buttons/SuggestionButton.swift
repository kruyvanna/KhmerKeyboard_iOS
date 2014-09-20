//
//  SuggestionButton.swift
//  ELDeveloperKeyboard
//
//  Created by Eric Lin on 2014-07-04.
//  Copyright (c) 2014 Eric Lin. All rights reserved.
//

import Foundation
import UIKit

/**
    The method declared in the SuggestionButtonDelegate protocol allow the adopting delegate to respond to messages from the SuggestionButton class, handling button presses.
*/
protocol SuggestionButtonDelegate { // FIXME: Need to change this to SuggestionButtonDelegate: class and make delegate property weak after bug is fixed.
    /**
        Respond to the SuggestionButton being pressed.
    
        :param: button The SuggestionButton that was pressed.
    */
    func handlePressForButton(button: SuggestionButton)
}

class SuggestionButton: UIButton {
    
    // MARK: Properties
    
    var delegate: SuggestionButtonDelegate?
    
    var title: String {
        didSet {
            setTitle(title, forState: .Normal)
        }
    }
    
    // MARK: Constructors
    
    init(frame: CGRect, title: String, delegate: SuggestionButtonDelegate?) {
        self.title = title
        self.delegate = delegate
        
        super.init(frame: frame)
        
        self.setTitle(title, forState: .Normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18.0)
        self.titleLabel?.textAlignment = .Center
        self.setTitleColor(UIColor(white: 238.0/255, alpha: 1), forState: .Normal)
        self.setTitleColor(UIColor(red: 119.0/255, green: 198.0/255, blue: 237.0/255, alpha: 1.0), forState: .Highlighted)
        self.titleLabel?.sizeToFit()
        self.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Event handlers
    
    func buttonPressed(button: SuggestionButton) {
        delegate?.handlePressForButton(self)
    }
}