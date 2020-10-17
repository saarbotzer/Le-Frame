//
//  Global Variables.swift
//  Le Frame
//
//  Created by Saar Botzer on 17/10/2020.
//  Copyright © 2020 Saar Botzer. All rights reserved.
//

import UIKit

public let appStoreUrlString: String = "https://apps.apple.com/il/app/royal-frame/id1490916476"
public let privacyPolicyUrlString : String = "http://www.freeprivacypolicy.com/privacy/view/2a29fd7a265d51d96bf75c8f422b751c"
public let testingAdUnitID: String = "ca-app-pub-3940256099942544/2934735716"
public let actualAdUnitID: String = "ca-app-pub-6790454182464184/3177122320"

// Testing
public let isTesting            : Bool          = false
public let testShowTaps         : Bool          = false
public let testShowOnboarding   : Bool          = false
public let testShowAdsMode      : ShowAdsMode   = .testingWithoutAds

// MARK: - Custom Colors
extension UIColor {
    // TODO: Document
    /// #FCD600
    static let frameGold: UIColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
    
    /// #hex
    static let frameDarkGold: UIColor = UIColor(red: 0.78, green: 0.64, blue: 0, alpha: 1)
    
    /// #hex
    static let frameBackgroundOverlay: UIColor = UIColor(red: 0.65, green: 0.8, blue: 0.65, alpha: 0.65)
}
