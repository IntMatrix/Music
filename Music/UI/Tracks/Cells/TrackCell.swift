//
//  TrackCell.swift
//  Music
//
//  Created by Maria on 9/6/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift

class TrackCell: UICollectionViewCell {
    
    private (set) open var disposeBag = CompositeDisposable()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
        disposeBag = CompositeDisposable()
    }
    
    deinit {
        disposeBag.dispose()
    }
    
}
