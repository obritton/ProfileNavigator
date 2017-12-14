//
//  ProfileManager.swift
//  ProfileNavigator
//
//  Created by Ontario Britton on 12/13/17.
//  Copyright © 2017 Ontario Britton. All rights reserved.
//

import Foundation

//Holds all the basic info for a Profile
struct Profile {
    let name : String
    let username : String
    let dob : String
    let gender : String
    
    let mobile : String
    let phone: String
    let email : String
    
    let addressLine1 : String
    let addressLine2 : String
    
    let photoURLStr : String
}

//Serves up Profiles from cache and gets new ones from the server
class ProfileManager {
    static let shared = ProfileManager()
    var profileArr = [Profile]()
    var currentProfileIndex = 0
    
    //Get a profile before or after the current Profile
    func getProfile(offsetFromCurrentProfile: Int, completionHandler: @escaping (_ success: Bool, _ profile: Profile?) ->Void) {
        currentProfileIndex += offsetFromCurrentProfile
        getProfile(at: currentProfileIndex, completionHandler: completionHandler)
    }
    
    //Get a Profile by index from the array of cached profiles
    //  or request a new one from the service if needed
    private func getProfile(at index: Int, completionHandler: @escaping (_ success: Bool, _ profile: Profile?) ->Void) {
        switch index{
        case let index where index < 0:
            completionHandler(true, nil)
        case 0..<profileArr.count:
            completionHandler(true, profileArr[currentProfileIndex])
        default:
            ProfileService.shared.getRandomProfile { (success, profile) in
                if let profile = profile {
                    self.profileArr.append(profile)
                }
                completionHandler(success, profile)
            }
        }
    }
}
