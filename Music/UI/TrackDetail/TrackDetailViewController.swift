//
//  TrackDetailViewController.swift
//  Music
//
//  Created by Maria on 9/6/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift

class TrackDetailViewController: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var controlsBar: UIToolbar!
    @IBOutlet weak var rewindButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var pauseButton: UIBarButtonItem!
    @IBOutlet var viewModel: TrackDetailViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTrackData()
        setupPlayerControls()
    }
    
    private func setupTrackData() {
        viewModel.track
            .map{ $0?.title ?? "Track Detail" }
            .bind(to: rx.title)
            .disposed(by: disposeBag)
        
        viewModel.track
            .flatMap { $0?.image.catchErrorJustReturn(#imageLiteral(resourceName: "no_track")) ?? Observable.empty() }
            .bind(to: imageButton.rx.backgroundImage(for: .normal))
            .disposed(by: disposeBag)
    }
    
    private func setupPlayerControls() {
        imageButton.rx.action = viewModel.playAction
        rewindButton.rx.action = viewModel.rewindAction
        playButton.rx.action = viewModel.playAction
        pauseButton.rx.action = viewModel.pauseAction
        forwardButton.rx.action = viewModel.forwardAction
        
        viewModel.playbackState
            .map{[weak self] state -> [UIBarButtonItem] in
                guard let strongSelf = self  else { return [] }
                let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                return [space, strongSelf.rewindButton, space,
                        state == .active ? strongSelf.pauseButton : strongSelf.playButton,
                        space, strongSelf.forwardButton, space]
            }
            .subscribe(onNext: {
                [weak self] items in
                self?.controlsBar.setItems(items, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}


