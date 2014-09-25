//
//  DefaultLanguageProvider.swift
//  ELDeveloperKeyboard
//
//  Created by Eric Lin on 2014-07-02.
//  Copyright (c) 2014 Eric Lin. All rights reserved.
//

import Foundation

/**
    A default implementation of the LanguageProvider interface, representing no specific programming language. Secondary and tertiary characters match their respective positions on a standard QWERTY keyboard.
*/
class DefaultLanguageProvider: LanguageProvider {
    lazy var language = "Default"
    lazy var secondaryCharacters = [
        ["ឈ", "ឺ", "ែ", "ឬ", "ទ", "ួ", "ូ", "ី", "ៅ", "ភ"],
        ["ាំ", "ៃ", "ឌ", "ធ", "អ", "ះ", "ញ", "គ", "ឡ", "៉"],
        ["ឍ", "ឃ", "ជ", "េះ", "ព", "ណ", "ំ"]
    ]
    lazy var tertiaryCharacters = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["ឦ", "%", "៌", "៍", "៊", "៏", "័", "៎", "ៗ", "ៈ"],
        ["៛", "(", ")", "ឩ",",", ".", ";"]
    ]
    lazy var shiftCharacters = [
        ["១", "២", "៣", "៤", "៥", "៦", "៧", "៨", "៩", "០"],
        ["ឥ", "ឧ", "ឱ", "ឪ", "ឲ", "ឯ", "ឫ", "ឭ", "ឮ", "ឰ"],
        ["@", "ៀ", "ឿ", "៖", "ោះ",  "ុះ", "ុំ"]
    ]
    lazy var autocapitalizeAfter = [String]()
    lazy var suggestionDictionary = [ WeightedString(term: "ការងារ", weight: 1),
        WeightedString(term: "ខ្មែរ", weight: 1)
    ]
}