//
//  TrackDetailViewModel.swift
//  Music
//
//  Created by Maria on 9/6/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Action

class TrackDetailViewModel: NSObject {
    
    @IBOutlet weak var viewController: TrackDetailViewController!
    let networkService = NetworkService.shared
    
    let track =  BehaviorSubject<Track?>(value: nil)
    let disposeBag = DisposeBag()
    
    let playbackState = TrackPlayer.shared.playbackState
    
    // MARK: - Setup track for TrackPlayer
    
    func setupTrack(_ track: Track) {
        self.track.onNext(track)
        
        guard let urlString = track.streamUrl else { return }
        
        let streamPath = urlString + "?client_id=\(MusicAPI.clientID)"
        let url = URL(string: streamPath)!
        
        TrackPlayer.shared.setTrack(url)
    }
    
    // MARK: - Actions
    
    lazy var playAction = CocoaAction { _ in
        TrackPlayer.shared.play()
        return .empty()
    }
    
    lazy var pauseAction = CocoaAction { _ in
        TrackPlayer.shared.pause()
        return .empty()
    }
    
    lazy var rewindAction = CocoaAction { _ in
        TrackPlayer.shared.rewind()
        return .empty()
    }
    
    lazy var forwardAction = CocoaAction { _ in
        TrackPlayer.shared.forward()
        return .empty()
    }
    
    // MARK: - Deinit
    
    deinit {
        TrackPlayer.shared.stop()
    }
}
