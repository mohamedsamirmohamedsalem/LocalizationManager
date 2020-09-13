//
//  LocalizationManager.swift
//  LocalizationManager
//
//  Created by Mohamed Samir on 9/13/20.
//  Copyright © 2020 Mohamed Samir. All rights reserved.
//


import Foundation
import UIKit

// inherit class to set initialized value with week reference.
protocol LocalizationDelegate: class {
    func resetApp()
}

class LocalizationManager: NSObject {
    enum LanguageDirection {
        case leftToRight
        case rightToLeft
    }
    
    enum Language: String {
        case English = "en"
        case Arabic = "ar"
    }
    
    static let shared = LocalizationManager()
    // used to reload current bundle of application instead of colse the app
    //and reopen it again for listening new bundle and make change.
    private var bundle: Bundle? = nil
    //stands for user key preference language
    private var languageKey = "UKPrefLang"
    weak var delegate: LocalizationDelegate?
    
    // get currently selected language from user defaults
    func getLanguage() -> Language? {
        if let languageCode = UserDefaults.standard.string(forKey: languageKey), let language = Language(rawValue: languageCode) {
            return language
        }
        return nil
    }
    
    //for making app open with language that is the device language
    // check if the language is available
    private func isLanguageAvailable(_ code: String) -> Language? {
        var finalCode = ""
        if code.contains("ar") {
            finalCode = "ar"
        } else if code.contains("en") {
            finalCode = "en"
        }
        return Language(rawValue: finalCode)
    }
    
    // check the language direction
    private func getLanguageDirection() -> LanguageDirection {
        if let lang = getLanguage() {
            switch lang {
            case .English:
                return .leftToRight
            case .Arabic:
                return .rightToLeft
            }
        }
        return .leftToRight
    }
    
    // get localized string for a given code from the active bundle
    func localizedString(for key: String, value comment: String) -> String {
        let localized = bundle!.localizedString(forKey: key, value: comment, table: nil)
        return localized
    }
    
    // set language for localization
    func setLanguage(language: Language) {
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "LocalizationManager") {
            bundle = Bundle(path: path)
        } else {
            // fallback
            resetLocalization()
        }
        UserDefaults.standard.synchronize()
        resetApp()
    }
    
    // reset bundle
    func resetLocalization() {
        bundle = Bundle.main
    }
    
    // reset app for the new language
    func resetApp() {
        let dir = getLanguageDirection()
        var semantic: UISemanticContentAttribute!
        switch dir {
        case .leftToRight:
            semantic = .forceLeftToRight
        case .rightToLeft:
            semantic = .forceRightToLeft
        }
        UITabBar.appearance().semanticContentAttribute = semantic
        UIView.appearance().semanticContentAttribute = semantic
        UINavigationBar.appearance().semanticContentAttribute = semantic
        delegate?.resetApp()
    }
    
    // configure startup language
    func setAppInnitLanguage() {
        if let selectedLanguage = getLanguage() {
            setLanguage(language: selectedLanguage)
        } else {
            // no language was selected
            let languageCode = Locale.preferredLanguages.first
            if let code = languageCode, let language = isLanguageAvailable(code) {
                setLanguage(language: language)
            } else {
                // default fall back
                setLanguage(language: .English)
            }
        }
        resetApp()
    }
}

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self, value: "")
    }
}
