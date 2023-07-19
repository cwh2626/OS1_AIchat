//
//  Environment.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/07/03.
//

import Foundation

public enum Environment {
    
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let gptApiKey = "GPT_API_KEY"
            static let AdMobBannerADId = "ADMOB_BANNER_AD_ID"
            static let AdMobRewardADId = "ADMOB_REWARD_AD_ID"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // MARK: - Plist values
    static let gptAPIKey: String = {
        guard let gptKey = Environment.infoDictionary[Keys.Plist.gptApiKey] as? String else {
            fatalError("GPT API Key not set in plist for this environment")
        }
        return gptKey
    }()
    
    static let AdMobBannerADId: String = {
        guard let id = Environment.infoDictionary[Keys.Plist.AdMobBannerADId] as? String else {
            fatalError("AdMobBannerADId not set in plist for this environment")
        }
        return id
    }()
    
    static let AdMobRewardADId: String = {
        guard let id = Environment.infoDictionary[Keys.Plist.AdMobRewardADId] as? String else {
            fatalError("AdMobRewardADId not set in plist for this environment")
        }
        return id
    }()
}

