//
//  MusicAPI.swift
//  Music
//
//  Created by Maria on 9/5/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import Moya

enum MusicAPI {
    
    //client id was hidden 
    static let clientID = "CLIENT_ID"
    
    case getTracks(Track.SearchQuery)
}

extension MusicAPI: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getTracks:
            return URL(string: "https://api.soundcloud.com")!
        }
    }
    
    var path: String {
        switch self {
        case .getTracks:
            return "/tracks"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTracks:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getTracks:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var parameters: [String:Any] {
        switch self {
        case .getTracks(let query):
            return ["client_id"     : MusicAPI.clientID,
                    "q"             : query.title,
                    "limit"         : query.pageLimit,
                    "streamable"    : "true"]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getTracks:
            return ["Content-Type": "application/json", "Accept": "application/json"]
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
}
