//
//  MyBrightonAppIntentsPackage.swift
//  My Brighton
//
//  Created by Neo Salmon on 29/08/2025.
//

import LearnKit
import TimetableIntents
import AppIntents

public struct MyBrightonAppIntentsPackage: AppIntentsPackage {
    public static var includedPackages: [any AppIntentsPackage.Type] {
        [TimetableAppIntentsPackage.self, LearnKitAppIntentsPackage.self]
    }
}
