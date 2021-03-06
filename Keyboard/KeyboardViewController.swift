//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Eric Lin on 2014-07-02.
//  Copyright (c) 2014 Eric Lin. All rights reserved.
//

import Foundation
import UIKit

/**
    An iOS custom keyboard extension written in Swift designed to make it much, much easier to type code on an iOS device.
*/
class KeyboardViewController: UIInputViewController, CharacterButtonDelegate, SuggestionButtonDelegate, TouchForwardingViewDelegate {

    // MARK: Constants
    
    private let primaryCharacters = [
        ["ឆ", "ឹ", "េ", "រ", "ត", "យ", "ុ", "ិ", "ោ", "ផ"],
        ["ា", "ស", "ដ", "ថ", "ង", "ហ", "្", "ក", "ល", "់"],
        ["ឋ", "ខ", "ច", "វ", "ប", "ន", "ម"]
    ]
    
    private let suggestionProvider: SuggestionProvider = SuggestionTrie()
    
    private let languageProviders = CircularArray(items: [DefaultLanguageProvider()] as [LanguageProvider])
    
    private let spacing: CGFloat = 4.0
    private let predictiveTextBoxHeight: CGFloat = 38.0
    private var predictiveTextButtonWidth: CGFloat {
        return (self.view.frame.width - 4 * spacing) / 3.0
    }
    private var keyWidth: CGFloat {
        return (self.view.frame.width - 11 * spacing) / 10.0
    }
    private var keyHeight: CGFloat {
        return (self.view.frame.height - 5 * spacing - predictiveTextBoxHeight) / 4.0
    }
    
    // MARK: Interface
    
    private var swipeView: SwipeView!
    private var predictiveTextScrollView: PredictiveTextScrollView!
    private var suggestionButtons = [SuggestionButton]()
    
    private lazy var characterButtons: [[CharacterButton]] = [
        [],
        [],
        []
    ]
    private var shiftButton: KeyButton!
    private var deleteButton: KeyButton!
    private var altButton: KeyButton!
    private var nextKeyboardButton: KeyButton!
    private var spaceButton: KeyButton!
    private var returnButton: KeyButton!
    private var currentLanguageLabel: UILabel!
    private var popupButton: UIButton!
    

    // MARK: Timers
    
    private var deleteButtonTimer: NSTimer?
    private var spaceButtonTimer: NSTimer?
    
    // MARK: Properties
    
    private var proxy: UITextDocumentProxy {
        return self.textDocumentProxy as UITextDocumentProxy
    }
    
    private var lastWordTyped: String? {
        if let documentContextBeforeInput = proxy.documentContextBeforeInput as NSString? {
            let length = documentContextBeforeInput.length
            if length > 0 && NSCharacterSet.letterCharacterSet().characterIsMember(documentContextBeforeInput.characterAtIndex(length - 1)) {
                let components = documentContextBeforeInput.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet) as [String]
                return components[components.endIndex - 1]
            }
        }
        return nil
    }

    private var languageProvider: LanguageProvider = DefaultLanguageProvider() {
        didSet {
            for (rowIndex, row) in enumerate(characterButtons) {
                for (characterButtonIndex, characterButton) in enumerate(row) {
                    characterButton.secondaryCharacter = languageProvider.secondaryCharacters[rowIndex][characterButtonIndex]
                    characterButton.tertiaryCharacter = languageProvider.tertiaryCharacters[rowIndex][characterButtonIndex]
                }
            }
            currentLanguageLabel.text = languageProvider.language
            suggestionProvider.clear()
            suggestionProvider.loadWeightedStrings(languageProvider.suggestionDictionary)
        }
    }
    
    private enum SwipeDirection {
        case Up, Down, Left, Right
    }
    
    private var swipeDirection: SwipeDirection = .Up

    private enum ShiftMode {
        case Off, On
    }
    
    private var shiftMode: ShiftMode = .Off {
        didSet {
            shiftButton.selected = (shiftMode == .On)
            for row in characterButtons {
                for characterButton in row {
                    switch shiftMode {
                    case .Off:
                        characterButton.primaryLabel.text = characterButton.primaryCharacter
                        characterButton.secondaryLabel.text = characterButton.secondaryCharacter
                    case .On:
                        characterButton.primaryLabel.text = characterButton.shiftCharacter
                        characterButton.secondaryLabel.text = ""
                    }
                
                }
            }
        }
    }
    
    private enum AltMode {
        case Off, On
    }
    
    private var altMode: AltMode = .Off {
        didSet {
            altButton.selected = (altMode == .On)
            for row in characterButtons {
                for characterButton in row {
                    switch altMode {
                    case .Off:
                        characterButton.primaryLabel.text = characterButton.primaryCharacter
                        characterButton.secondaryLabel.text = characterButton.secondaryCharacter
                    case .On:
                        characterButton.primaryLabel.text = characterButton.tertiaryCharacter
                        characterButton.secondaryLabel.text = ""
                    }
                }
            }

        }
    }
    
    // MARK: Constructors
    // FIXME: Uncomment init methods when crash bug is fixed. Also need to move languageProvider initialization to constructor to prevent unnecessary creation of two DefaultLanguageProvider instances.
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        self.shiftMode = .Off
//        self.languageProvider = languageProviders.currentItem!
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }

//    required init(coder aDecoder: NSCoder!) {
//        fatalError("NSCoding not supported")
//    }
    
    // MARK: Overridden methods
    
    override func loadView() {
        let screenRect = UIScreen.mainScreen().bounds
        self.view = TouchForwardingView(frame: CGRectMake(0.0, predictiveTextBoxHeight, screenRect.width, screenRect.height - predictiveTextBoxHeight), delegate: self)
        self.view.backgroundColor = UIColor(red: 209.0/255, green: 213.0/255, blue: 219.0/255, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestionProvider.clear()
        suggestionProvider.loadWeightedStrings(languageProvider.suggestionDictionary)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initializeKeyboard()
    }
        
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        initializeKeyboard()
    }
    
    // MARK: Event handlers
    
    func shiftButtonPressed(sender: KeyButton) {
        altMode = .Off
        switch shiftMode {
        case .Off:
            shiftMode = .On
        case .On:
            shiftMode = .Off
        }
    }
    
    func altButtonPressed(sender: KeyButton) {
        shiftMode = .Off
        switch altMode {
        case .Off:
            altMode = .On
        case .On:
            altMode = .Off
        }
    }
    
    func deleteButtonPressed(sender: KeyButton) {
        switch proxy.documentContextBeforeInput {
        case let s where s?.hasSuffix("    ") == true: // Cursor in front of tab, so delete tab.
            for i in 0..<4 { // TODO: Update to use tab setting.
                proxy.deleteBackward()
            }
        default:
            proxy.deleteBackward()
        }
        updateSuggestions()
    }
    
    func handleLongPressForDeleteButtonWithGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            if deleteButtonTimer == nil {
                deleteButtonTimer = NSTimer(timeInterval: 0.1, target: self, selector: "handleDeleteButtonTimerTick:", userInfo: nil, repeats: true)
                deleteButtonTimer!.tolerance = 0.01
                NSRunLoop.mainRunLoop().addTimer(deleteButtonTimer!, forMode: NSDefaultRunLoopMode)
            }
        default:
            deleteButtonTimer?.invalidate()
            deleteButtonTimer = nil
            updateSuggestions()
        }
    }
    
    func handleSwipeLeftForDeleteButtonWithGestureRecognizer(gestureRecognizer: UISwipeGestureRecognizer) {
        // TODO: Figure out an implementation that doesn't use bridgeToObjectiveC, in case of funny unicode characters.
        if let documentContextBeforeInput = proxy.documentContextBeforeInput as NSString? {
            if documentContextBeforeInput.length > 0 {
                var charactersToDelete = 0
                switch documentContextBeforeInput {
                case let s where NSCharacterSet.letterCharacterSet().characterIsMember(s.characterAtIndex(s.length - 1)): // Cursor in front of letter, so delete up to first non-letter character.
                    let range = documentContextBeforeInput.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet().invertedSet, options: .BackwardsSearch)
                    if range.location != NSNotFound {
                        charactersToDelete = documentContextBeforeInput.length - range.location - 1
                    } else {
                        charactersToDelete = documentContextBeforeInput.length
                    }
                case let s where s.hasSuffix(" "): // Cursor in front of whitespace, so delete up to first non-whitespace character.
                    let range = documentContextBeforeInput.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet().invertedSet, options: .BackwardsSearch)
                    if range.location != NSNotFound {
                        charactersToDelete = documentContextBeforeInput.length - range.location - 1
                    } else {
                        charactersToDelete = documentContextBeforeInput.length
                    }
                default: // Just delete last character.
                    charactersToDelete = 1
                }
                
                for i in 0..<charactersToDelete {
                    proxy.deleteBackward()
                }
            }
        }
        updateSuggestions()
    }
    
    func handleDeleteButtonTimerTick(timer: NSTimer) {
        proxy.deleteBackward()
    }

    
    func spaceButtonPressed(sender: KeyButton) {
        for suffix in languageProvider.autocapitalizeAfter {
            if proxy.documentContextBeforeInput.hasSuffix(suffix) {
                shiftMode = .On
            }
        }
        proxy.insertText(" ")
        updateSuggestions()
    }
    
    func handleLongPressForSpaceButtonWithGestureRecognizer(gestureRecognizer: UISwipeGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            if spaceButtonTimer == nil {
                spaceButtonTimer = NSTimer(timeInterval: 0.1, target: self, selector: "handleSpaceButtonTimerTick:", userInfo: nil, repeats: true)
                spaceButtonTimer!.tolerance = 0.01
                NSRunLoop.mainRunLoop().addTimer(spaceButtonTimer!, forMode: NSDefaultRunLoopMode)
            }
        default:
            spaceButtonTimer?.invalidate()
            spaceButtonTimer = nil
            updateSuggestions()
        }
    }
    
    func handleSpaceButtonTimerTick(timer: NSTimer) {
        proxy.insertText(" ")
    }
    
    func returnButtonPressed(sender: KeyButton) {
        proxy.insertText("\n")
        updateSuggestions()
    }
    
    // MARK: CharacterButtonDelegate
    
    func handlePressForButton(button: CharacterButton) {
        
        if shiftMode == .On || altMode == .On {
            if shiftMode == .On {
                proxy.insertText(button.shiftCharacter)
            }else{
                proxy.insertText(button.tertiaryCharacter)
            }
        }else{
            proxy.insertText(button.primaryCharacter)
        }
        
        updateSuggestions()
    }
    
    func handleSwipeUpForButton(button: CharacterButton, recognizer: UIPanGestureRecognizer) {
        if shiftMode == .On || altMode == .On {
            return
        }
        
        if(recognizer.state == .Began){
            var translation = recognizer.translationInView(button)
            if(translation.x == 0 && translation.y < 0){
                showSwipeCharacter(button)
                swipeDirection = .Up
            }else{
                swipeDirection = .Down
            }
        }else if(recognizer.state == .Ended){
            if(swipeDirection == .Up){
                proxy.insertText(button.secondaryCharacter)
                updateSuggestions()
            }
            if(popupButton != nil){
                hideSwipeButton()
            }
        }
    }
    
    private func showSwipeCharacter(button: CharacterButton){
        var w = button.frame.width
        var h = button.frame.height
        var x = button.frame.origin.x
        var y = button.frame.origin.y - h
        
        popupButton = PopupButton(frame: CGRectMake(x, y, w, h));
        popupButton.setTitle(button.secondaryCharacter, forState: .Normal)
        self.view.addSubview(popupButton)
    }
    
    func hideSwipeButton(){
        popupButton.removeFromSuperview()
        popupButton = nil;
    }
    
    func handleSwipeDownForButton(button: CharacterButton) {
        proxy.insertText(button.tertiaryCharacter)
        if countElements(button.tertiaryCharacter) > 1 {
            proxy.insertText(" ")
        }
        updateSuggestions()
    }
    
    // MARK: SuggestionButtonDelegate
    
    func handlePressForButton(button: SuggestionButton) {
        if let lastWord = NSString.stringWithString(lastWordTyped!) {
            var count = lastWord.length
            while count > 0 {
                proxy.deleteBackward()
                count--
            }

            proxy.insertText(button.title + "​")
            for suggestionButton in suggestionButtons {
                suggestionButton.removeFromSuperview()
            }
        }
    }
    
    // MARK: TouchForwardingViewDelegate
    
    // TODO: Get this method to properly provide the desired behaviour.
    func viewForHitTestWithPoint(point: CGPoint, event: UIEvent?, superResult: UIView?) -> UIView? {
        for subview in view.subviews as [UIView] {
            let convertPoint = subview.convertPoint(point, fromView: view)
            if subview is KeyButton && subview.pointInside(convertPoint, withEvent: event) {
                return subview
            }
        }
        return superResult
    }
    
    // MARK: Helper methods
    
    private func initializeKeyboard() {
        for subview in self.view.subviews as [UIView] {
            subview.removeFromSuperview() // Remove all buttons and gesture recognizers when view is recreated during orientation changes.
        }

        addPredictiveTextScrollView()
        addShiftButton()
        addDeleteButton()
        addAltButton()
        addNextKeyboardButton()
        addSpaceButton()
        addReturnButton()
        addCharacterButtons()
        addSwipeView()
    }
    
    
    private func addPredictiveTextScrollView() {
        predictiveTextScrollView = PredictiveTextScrollView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, predictiveTextBoxHeight))
        self.view.addSubview(predictiveTextScrollView)
    }
    
    private func addShiftButton() {
        shiftButton = ControlButton(frame: CGRectMake(spacing, keyHeight * 2.0 + spacing * 3.0 + predictiveTextBoxHeight, keyWidth * 1.5 + spacing * 0.5, keyHeight))
        shiftButton.setTitle("\u{000021EA}", forState: .Normal)
        shiftButton.addTarget(self, action: "shiftButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(shiftButton)
    }
    
    private func addDeleteButton() {
        deleteButton = ControlButton(frame: CGRectMake(keyWidth * 8.5 + spacing * 9.5, keyHeight * 2.0 + spacing * 3.0 + predictiveTextBoxHeight, keyWidth * 1.5, keyHeight))
        deleteButton.setTitle("\u{0000232B}", forState: .Normal)
        deleteButton.addTarget(self, action: "deleteButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(deleteButton)
        
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressForDeleteButtonWithGestureRecognizer:")
        deleteButton.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
        
        let deleteButtonSwipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeftForDeleteButtonWithGestureRecognizer:")
        deleteButtonSwipeLeftGestureRecognizer.direction = .Left
        deleteButton.addGestureRecognizer(deleteButtonSwipeLeftGestureRecognizer)
    }
    
    private func addAltButton() {
        altButton = ControlButton(frame: CGRectMake(spacing, keyHeight * 3.0 + spacing * 4.0 + predictiveTextBoxHeight, keyWidth * 1.5 + spacing * 0.5, keyHeight))
        altButton.setTitle("\u{0000005E}", forState: .Normal)
        altButton.addTarget(self, action: "altButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(altButton)
    }
    
    private func addNextKeyboardButton() {
        nextKeyboardButton = ControlButton(frame: CGRectMake(keyWidth * 1.5 + spacing * 2.5, keyHeight * 3.0 + spacing * 4.0 + predictiveTextBoxHeight, keyWidth, keyHeight))
        nextKeyboardButton.setTitle("\u{0001F310}", forState: .Normal)
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        self.view.addSubview(nextKeyboardButton)
    }
    
    private func addSpaceButton() {
        spaceButton = KeyButton(frame: CGRectMake(keyWidth * 2.5 + spacing * 3.5, keyHeight * 3.0 + spacing * 4.0 + predictiveTextBoxHeight, keyWidth * 5.0 + spacing * 4.0, keyHeight))
        spaceButton.addTarget(self, action: "spaceButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(spaceButton)
        
        currentLanguageLabel = UILabel(frame: CGRectMake(0.0, 0.0, spaceButton.frame.width, spaceButton.frame.height * 0.33))
        currentLanguageLabel.font = UIFont(name: "HelveticaNeue", size: 12.0)
        currentLanguageLabel.adjustsFontSizeToFitWidth = true
        currentLanguageLabel.textColor = UIColor(white: 187.0/255, alpha: 1)
        currentLanguageLabel.textAlignment = .Center
        currentLanguageLabel.text = ""
        spaceButton.addSubview(currentLanguageLabel)
        
        let spaceButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressForSpaceButtonWithGestureRecognizer:")
        spaceButton.addGestureRecognizer(spaceButtonLongPressGestureRecognizer)
    }
    
    private func addReturnButton() {
        returnButton = ControlButton(frame: CGRectMake(keyWidth * 7.5 + spacing * 8.5, keyHeight * 3.0 + spacing * 4.0 + predictiveTextBoxHeight, keyWidth * 2.5 + spacing, keyHeight))
        returnButton.setTitle("\u{000023CE}", forState: .Normal)
        returnButton.addTarget(self, action: "returnButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(returnButton)
    }
    

    
    private func addCharacterButtons() {
        characterButtons = [
            [],
            [],
            []
        ] // Clear characterButtons array.
        
        var y = spacing + predictiveTextBoxHeight
        for (rowIndex, row) in enumerate(primaryCharacters) {
            var x: CGFloat
            switch rowIndex {
            case 1:
                x = spacing
            case 2:
                x = spacing * 2.5 + keyWidth * 1.5
            default:
                x = spacing
            }
            for (keyIndex, key) in enumerate(row) {
                let characterButton = CharacterButton(frame: CGRectMake(x, y, keyWidth, keyHeight), primaryCharacter: key,
                    secondaryCharacter: languageProvider.secondaryCharacters[rowIndex][keyIndex], tertiaryCharacter: languageProvider.tertiaryCharacters[rowIndex][keyIndex], shiftCharacter: languageProvider.shiftCharacters[rowIndex][keyIndex], delegate: self)
                self.view.addSubview(characterButton)
                characterButtons[rowIndex].append(characterButton)
                x += keyWidth + spacing
            }
            y += keyHeight + spacing
        }
    }
    
    private func addSwipeView() {
        swipeView = SwipeView(containerView: self.view, topOffset: predictiveTextBoxHeight)
        self.view.addSubview(swipeView)
    }
    
    private func moveButtonLabels(dx: CGFloat) {
        for (rowIndex, row) in enumerate(characterButtons) {
            for (characterButtonIndex, characterButton) in enumerate(row) {
                characterButton.secondaryLabel.frame.offset(dx: dx, dy: 0.0)
                characterButton.tertiaryLabel.frame.offset(dx: dx, dy: 0.0)
            }
        }
        currentLanguageLabel.frame.offset(dx: dx, dy: 0.0)
    }
    
    private func updateSuggestions() {
        for suggestionButton in suggestionButtons {
            suggestionButton.removeFromSuperview()
        }
        
        // TODO: Figure out an implementation that doesn't use bridgeToObjectiveC, in case of funny unicode characters.
        if let lastWord = lastWordTyped {
            var x = spacing
            for suggestion in suggestionProvider.suggestionsForPrefix(lastWord) {
                let suggestionButton = SuggestionButton(frame: CGRectMake(x, 0.0, predictiveTextButtonWidth, predictiveTextBoxHeight), title: suggestion, delegate: self)
                predictiveTextScrollView?.addSubview(suggestionButton)
                suggestionButtons.append(suggestionButton)
                x += predictiveTextButtonWidth + spacing
            }
            predictiveTextScrollView!.contentSize = CGSizeMake(x, predictiveTextBoxHeight)
        }
    }
}