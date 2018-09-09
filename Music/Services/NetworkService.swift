//
//  NetworkService.swift
//  Music
//
//  Created by Maria on 9/5/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class NetworkService {
    let provider = MoyaProvider<MusicAPI>()
    let jsonDecoder = JSONDecoder()
    let disposeBag = DisposeBag()
    
    static let shared = NetworkService()
    
    func getTracks(_ query: Track.SearchQuery) -> Single<[Track]> {
        return provider.rx.request(.getTracks(query))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map([Track].self, using: jsonDecoder)
    }

}
