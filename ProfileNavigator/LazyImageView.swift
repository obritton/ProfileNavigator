//
//  LazyImageView.swift
//  ProfileNavigator
//
//  Created by Ontario Britton on 12/13/17.
//  Copyright © 2017 Ontario Britton. All rights reserved.
//

import UIKit

//Downloads an image asyncronously and then displays it
class LazyImageView : UIImageView {
    //Load the image at the specified URL
    func loadURL( url : URL) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else {
                print(String(format: errorFormat, "Download failure", url.absoluteString))
                return
            }
            
            guard let image = UIImage(data: data) else {
                print(String(format: errorFormat, "Image Creation Failure", data.description))
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}
