//
//  Game.swift
//  GameLogger
//
//  Created by Henry Cooper on 22/08/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

@objc class Game: NSObject {
    
    var name: String?
    var releaseDate: Int?
    private var artwork: UIImage?
    private var artworkURL: URL?
    
    init(dictionary: [String:Any]) {
        
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let releaseDate = dictionary["first_release_date"] as? Int {
            self.releaseDate = releaseDate
        }
        
        if let artworkDict = dictionary["cover"] as? [String: Any], let artworkString = artworkDict["url"] as? String  {
            print(artworkString)
            self.artworkURL = URL(string: artworkString)
        }
        
        super.init()
    }
    
    func getArtwork() {
        
        if artwork == nil {
            guard let artworkURL = artworkURL else { artwork = #imageLiteral(resourceName: "noimage"); return }
            NetworkManager.downloadImageFrom(artworkURL) { (image) in
                self.artwork = image
            }
        }
    }

}
