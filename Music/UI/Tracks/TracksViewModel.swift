//
//  TracksViewModel.swift
//  Music
//
//  Created by Maria on 9/5/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

class TracksViewModel: NSObject {
    
    enum TrackStyle: String {
        case list
        case tile
    }
    
    @IBOutlet weak var viewController: UIViewController!
    
    let networkService = NetworkService.shared
    
    let loading = BehaviorSubject<Bool>(value: false)
    let inputText = BehaviorRelay<String?>(value: nil)
    let tracks = BehaviorSubject<[Track]>(value: [])
    let cancelPreviousLoads = PublishSubject<Void>()
    let trackStyle = BehaviorRelay<TrackStyle>(value: UserDefaults.standard.bool(forKey: "trackStyle") ? .tile : .list)
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        trackStyle.subscribe(onNext: { (trackStyle) in
            UserDefaults.standard.set( trackStyle == .tile ? true : false, forKey: "trackStyle")
        }).disposed(by: disposeBag)
        
        loading.filter{ $0 == true }
            .subscribe(onNext: { _ in
                self.cancelPreviousLoads.onNext(())
            }).disposed(by: disposeBag)
        
        loadTracks("").take(1)
            .subscribe(onNext: { [weak self] (tracks) in
            guard let strongSelf = self else { return }
            strongSelf.tracks.onNext(tracks)
        }).disposed(by: disposeBag)
        
        inputText
            .flatMap{ $0.map(Observable.just) ?? .empty() }
            .distinctUntilChanged()
            .flatMap{ self.loadTracks($0) }
            .bind(to: self.tracks)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Load tracks
    
    private func loadTracks(_ text: String) -> Observable<[Track]> {
        let query = Track.SearchQuery(title:text)
        
        loading.onNext(true)
        
        return networkService.getTracks(query)
            .catchError{ _ in Single.just([]) }
            .asObservable()
            .takeUntil(cancelPreviousLoads.asObservable())
            .do(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.loading.onNext(false)
            })
    }

    // MARK: - Actions
    
    lazy var listAction = CocoaAction { [weak self] _ in
        guard let strongSelf = self else { return .empty() }
        strongSelf.trackStyle.accept(.list)
        return .empty()
    }
    
    lazy var tileAction = CocoaAction { [weak self] _ in
        guard let strongSelf = self else { return .empty() }
        strongSelf.trackStyle.accept(.tile)
        return .empty()
    }
    
    lazy var openTrackAction = Action<Track, Void> { [weak self] track in
        guard let strongSelf = self,
            let navigationController = strongSelf.viewController.navigationController
            else { return .empty() }
        
        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: String(describing: TrackDetailViewController.self)) as! TrackDetailViewController
        viewController.viewModel.setupTrack(track)
        navigationController.pushViewController(viewController, animated: true)
        return .empty()
    }
}
