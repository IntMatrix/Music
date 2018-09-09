//
//  TrackPlayer.swift
//  Music
//
//  Created by Maria on 9/6/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

class TrackPlayer {
    
    static let shared: TrackPlayer = TrackPlayer()
    
    private let player: AVPlayer = AVPlayer()
    private var url: URL?

    enum PlaybackState {
        case inactive
        case active
    }
    
    var playbackState = BehaviorSubject<PlaybackState>(value: .inactive)
    
    // MARK: - Public calls
    
    func setTrack(_ url: URL) {
        self.url = url
        setupPlayerItem()
    }
    
    func play() {
        player.play()
        setupPlaybackState()
    }
    
    func pause() {
        player.pause()
        setupPlaybackState()
    }
    
    func stop() {
        pause()
        self.url = nil
        player.replaceCurrentItem(with: nil)
    }
    
    fileprivate let seekDuration: Float64 = 5
    
    func rewind() {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
        player.seek(to: time2, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func forward() {
        guard let duration  = player.currentItem?.duration else {
            return
        }
        
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < (CMTimeGetSeconds(duration) - seekDuration) {
            let time2: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
            player.seek(to: time2, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    // MARK: - Private setup
    
    private func setupPlayerItem() {
        guard let currentUrl = url else {
            return
        }
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: currentUrl)
        player.replaceCurrentItem(with: playerItem)
    }
    
    private func setupPlaybackState() {
        if isPlaying() {
            playbackState.onNext(.active)
        }
        else {
            playbackState.onNext(.inactive)
        }
    }

    private func isPlaying() -> Bool {
        if player.currentItem == nil {
            return false
        }
        return player.rate != 0.0
    }

}
