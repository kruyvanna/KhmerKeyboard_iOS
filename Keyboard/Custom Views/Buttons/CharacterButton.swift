//
//  CharacterButton.swift
//  ELDeveloperKeyboard
//
//  Created by Eric Lin on 2014-07-02.
//  Copyright (c) 2014 Eric Lin. All rights reserved.
//

import Foundation
import UIKit

/**
    The methods declared in the CharacterButtonDelegate protocol allow the adopting delegate to respond to messages from the CharacterButton class, handling button presses and swipes.
*/
protocol CharacterButtonDelegate { // FIXME: Need to change this to CharacterButtonDelegate: class and make delegate property weak after bug is fixed.
    /**
        Respond to the CharacterButton being pressed.
        
        :param: button The CharacterButton that was pressed.
    */
    func handlePressForButton(button: CharacterButton)
    
    /**
        Respond to the CharacterButton being up-swiped.
     
        :param: button The CharacterButton that was up-swiped.
    */
    func handleSwipeUpForButton(button: CharacterButton)
    
    /**
        Respond to the CharacterButton being down-swiped.
     
        :param: button The CharacterButton that was down-swiped.
    */
    func handleSwipeDownForButton(button: CharacterButton)
}

/**
    CharacterButton is a KeyButton subclass associated with three characters (primary, secondary, and tertiary) as well as three gestures (press, swipe up, and swipe down).
*/
class CharacterButton: KeyButton {
    
    // MARK: Properties
    
    var delegate: CharacterButtonDelegate?
    
    var primaryCharacter: String {
        didSet {
            if primaryLabel != nil {
                primaryLabel.text = primaryCharacter
            }
        }
    }
    var secondaryCharacter: String {
        didSet {
            if secondaryLabel != nil {
                secondaryLabel.text = secondaryCharacter
            }
        }
    }
    var tertiaryCharacter: String {
        didSet {
            if tertiaryLabel != nil {
                tertiaryLabel.text = tertiaryCharacter
            }
        }
    }
    
    var shiftCharacter = ""
    
    private(set) var primaryLabel: UILabel!
    private(set) var secondaryLabel: UILabel!
    private(set) var tertiaryLabel: UILabel!
    
    // MARK: Constructors
    
    init(frame: CGRect, primaryCharacter: String, secondaryCharacter: String, tertiaryCharacter: String, shiftCharacter: String, delegate: CharacterButtonDelegate?) {
        
        self.primaryCharacter = primaryCharacter
        self.secondaryCharacter = secondaryCharacter
        self.tertiaryCharacter = tertiaryCharacter
        self.shiftCharacter = shiftCharacter
        self.delegate = delegate
        
        super.init(frame: frame)
        
        self.primaryLabel = UILabel(frame: CGRectMake(frame.width * 0.2, 0.0, frame.width * 0.8, frame.height * 0.95))
        self.primaryLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.primaryLabel.textColor = UIColor(white: 0.0/255, alpha: 1.0)
        self.primaryLabel.textAlignment = .Left
        self.primaryLabel.text = primaryCharacter
        self.primaryLabel.backgroundColor = UIColor(white: 255.0/255, alpha: 0.0)
        self.addSubview(self.primaryLabel)
        
        self.secondaryLabel = UILabel(frame: CGRectMake(0.0, 0.0, frame.width * 0.9, frame.height * 0.3))
        self.secondaryLabel.font = UIFont(name: "HelveticaNeue", size: 8.0)
        self.secondaryLabel.adjustsFontSizeToFitWidth = true
        self.secondaryLabel.textColor = UIColor(white: 167.0/255, alpha: 1.0)
        self.secondaryLabel.textAlignment = .Right
        self.secondaryLabel.text = secondaryCharacter
        self.addSubview(self.secondaryLabel)
//
//        self.tertiaryLabel = UILabel(frame: CGRectMake(0.0, frame.height * 0.65, frame.width * 0.9, frame.height * 0.25))
//        self.tertiaryLabel.font = UIFont(name: "HelveticaNeue", size: 8.0)
//        self.tertiaryLabel.textColor = UIColor(white: 187.0/255, alpha: 1.0)
//        self.tertiaryLabel.adjustsFontSizeToFitWidth = true
//        self.tertiaryLabel.textAlignment = .Right
//        self.tertiaryLabel.text = tertiaryCharacter
//        self.addSubview(self.tertiaryLabel)
        
        self.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "buttonSwipedUp:")
        swipeUpGestureRecognizer.direction = .Up
        self.addGestureRecognizer(swipeUpGestureRecognizer)
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "buttonSwipedDown:")
        swipeDownGestureRecognizer.direction = .Down
        self.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Event handlers
    
    func buttonPressed(sender: KeyButton) {
        delegate?.handlePressForButton(self)
    }
    
    func buttonSwipedUp(swipeUpGestureRecognizer: UISwipeGestureRecognizer) {
        delegate?.handleSwipeUpForButton(self)
    }
    
    func buttonSwipedDown(swipeDownGestureRecognizer: UISwipeGestureRecognizer) {
        delegate?.handleSwipeDownForButton(self)
    }
}