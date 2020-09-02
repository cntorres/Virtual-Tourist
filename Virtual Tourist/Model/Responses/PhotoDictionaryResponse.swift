//
//  PhotoDictionaryResponse.swift
//  Virtual Tourist
//
//  Created by Courtney Torres on 8/28/20.
//  Copyright © 2020 Courtney Torres. All rights reserved.
//

import Foundation
import UIKit








struct PhotoDictionaryResponse : Codable {
    let photos : Pages
}

struct Pages : Codable {
    let page : Int
    let pages : Int
    let perpage : Int
    let total : String
    let photo : [PhotoInfo]
}


struct PhotoInfo : Codable {
    let id : String
    let owner : String
    let secret : String
    let server : String
    let farm : Int
    let title : String
    let ispublic : Int
    let isfriend : Int
    let isfamily : Int
}

