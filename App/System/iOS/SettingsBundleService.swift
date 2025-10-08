//
//  SettingsBundleService.swift
//  My Brighton
//
//  Created by Neo on 05/09/2023.
//

import Foundation

@MainActor
class SettingsBundleService {
    
    struct SettingsBundleKeyConstant {
        static let Build = "version"
    }
    
    static let shared = SettingsBundleService()
    
    private init() {
        setMainBundle()
        configureSettingsBundle()
    }
    
    let userDefaults = UserDefaults.standard
    var mainBundleDict: [String: Any]?
    
    
    // Setting bundle register and set values of setting bundle in UserDefault preferences.
    
    private func configureSettingsBundle() {
        
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension:"bundle") else {
            print("Settings.bundle not found")
            return;
        }
        
        guard let rootSettings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")) else {
            print("Root.plist not found in settings bundle")
            return
        }
        
        guard let rootPreferences = rootSettings.object(forKey: "PreferenceSpecifiers") as? [[String: AnyObject]] else {
            print("Root.plist has invalid format")
            return
        }
        
        var defaultsToRegister = [String: AnyObject]()
        
        for pref in rootPreferences {
            if let key = pref["Key"] as? String, let val = pref["DefaultValue"] {
                print("\(key)==> \(val)")
                defaultsToRegister[key] = val
            }
        }
        
        userDefaults.register(defaults: defaultsToRegister)
        userDefaults.synchronize()
    }
    
    private func setMainBundle() {
        if mainBundleDict == nil {
            if let dict = Bundle.main.infoDictionary {
                mainBundleDict = dict
            }
        }
    }
    
    //Setting the Application build info from the infoPlist into the settings app
    //Make sure the names for the keys is perfect as assign in Setting bundle plist.
    
    func setVersionInfo() {
        guard let appVersion = mainBundleDict?[String(kCFBundleVersionKey)] as? String else { return }
        guard let appBuildNumber = mainBundleDict?["CFBundleShortVersionString"] as? String else { return }
        userDefaults.set("\(appBuildNumber) (\(appVersion))", forKey: SettingsBundleKeyConstant.Build)
        print("Build info set")
    }
}
