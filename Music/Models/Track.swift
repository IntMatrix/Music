//
//  Track.swift
//  Music
//
//  Created by Maria on 9/5/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation

struct Track: Codable {
    
    var id: Int = 0
    var title: String?
    var uri: String?
    var streamUrl: String?
    var artworkUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case uri
        case streamUrl = "stream_url"
        case artworkUrl = "artwork_url"
    }
    
    struct SearchQuery {
        var title: String
        var pageLimit: Int = 50
        
        init(title: String) {
            self.title = title
        }
    }
}
