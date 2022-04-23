//
//  AssetDecoder.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import Foundation

class AssetDecoder: Decodable {
    class Asset: Decodable {
        class Collection: Decodable {
            var name: String?
        }
        var id: Int
        var image_url: String?
        var name: String?
        var description: String?
        var permalink: String?
        var collection: Collection?
    }
    var next: String?
    var previous: String?
    var assets: [Asset]
}
