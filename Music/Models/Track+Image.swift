//
//  ImageService.swift
//  Music
//
//  Created by Maria on 9/7/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import Kingfisher
import RxKingfisher
import RxSwift

extension Track {

    var image:Observable<UIImage> {
        guard let imagePath = artworkUrl else { return  Observable.just(#imageLiteral(resourceName: "no_track"))  }
        return KingfisherManager.shared.rx.retrieveImage(with: URL(string: imagePath)!).asObservable()
    }
    
}

