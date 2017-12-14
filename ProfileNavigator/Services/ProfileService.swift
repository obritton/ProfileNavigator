//
//  ProfileService.swift
//  ProfileNavigator
//
//  Created by Ontario Britton on 12/13/17.
//  Copyright © 2017 Ontario Britton. All rights reserved.
//

import Foundation

let profileURLStr = "https://randomuser.me/api/"
let errorFormat = "ERROR: %s: %s"
let dateFormat = "yyyy-mm-dd hh:mm:ss"

//Downloads a randomuser.me profile JSON
//  and converts it to a Profile
class ProfileService {
    static let shared = ProfileService()
    
    //Get a new random profile from the server
    func getRandomProfile( completionHandler: @escaping (_ success: Bool, _ profile: Profile?) -> ()) {
        guard let profileURL = URL(string: profileURLStr) else {
            print(String(format: errorFormat, "Bad Profile URL", profileURLStr))
            completionHandler(false, nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: profileURL) else {
                print(String(format: errorFormat, "Download failure", profileURL.absoluteString))
                completionHandler(false, nil)
                return
            }
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                let profileDict = jsonObject as? [String : Any] else {
                    print(String(format: errorFormat, "Serialization failure", ""))
                    completionHandler(false, nil)
                    return
            }
            DispatchQueue.main.async {
                guard let profileArr = profileDict["results"] as? [Any],
                    let profileJSON = profileArr.first as? [String : Any] else {
                        print(String(format: errorFormat, "No profile in results", profileDict.description))
                        completionHandler(false, nil)
                        return
                }
                
                guard let profile = self.createProfile(json: profileJSON) else {
                    print(String(format: errorFormat, "Profile creation failure", profileDict))
                    completionHandler(false, nil)
                    return
                }
                completionHandler(true, profile)
            }
        }
    }
    
    //Convert the server's JSON data to a Profile object
    func createProfile( json: Dictionary<String, Any>) -> Profile? {
        guard let nameJSON  = json["name"]    as? [String:String] else  {   return nil  }
        guard let loginJSON = json["login"]   as? [String:String] else  {   return nil  }
        guard let picJSON   = json["picture"] as? [String:String] else  {   return nil  }
        guard let gender    = json["gender"]  as? String else           {   return nil  }
        guard let mobile    = json["cell"]    as? String else           {   return nil  }
        guard let phone     = json["phone"]   as? String else           {   return nil  }
        guard let email     = json["email"]   as? String else           {   return nil  }
        guard let dob       = json["dob"]     as? String else           {   return nil  }
        guard let firstName = nameJSON["first"] else                    {   return nil  }
        guard let lastName  = nameJSON["last"] else                     {   return nil  }
        guard let userName  = loginJSON["username"] else                {   return nil  }
        guard let picURLStr = picJSON["large"] else                     {   return nil  }
        
        guard let addressJSON = json["location"]      as? [String:Any],
            let street        = addressJSON["street"] as? String,
            let city          = addressJSON["city"]   as? String,
            let state         = addressJSON["state"]  as? String else   {   return nil  }
        
        let profile = Profile(
            name: "\(firstName) \(lastName)",
            username: userName,
            dob: dob,
            gender: gender,
            mobile: mobile,
            phone: phone,
            email: email,
            addressLine1: street,
            addressLine2: "\(city), \(state)",
            photoURLStr: picURLStr)
        return profile
    }
}
