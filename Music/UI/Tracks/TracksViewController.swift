//
//  TracksViewController.swift
//  Music
//
//  Created by Maria on 9/5/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift
import Hero

class TracksViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var viewModel: TracksViewModel!
    
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var tileButton: UIBarButtonItem!
    
    private var selectedItem:UICollectionViewCell? {
        didSet {
            oldValue?.hero.id = nil
            selectedItem?.hero.id = "animatingCell"
        }
    }
    
    private let disposeBag = DisposeBag()
    private var collectionDisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        setupToolbar()
    }

    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        let searchBar = searchController.searchBar
        
        Observable.merge(
            searchBar.rx.cancelButtonClicked.map{""},
            searchBar.rx.searchButtonClicked.map{ searchBar.text },
            searchBar.rx.value
                .filter{ _ in searchController.isActive }
                .debounce(0.2, scheduler: MainScheduler.instance)
            )
            .bind(to: viewModel.inputText)
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        viewModel.trackStyle.asObservable().subscribe(onNext: { (trackStyle) in
            switch trackStyle {
            case .list:
                self.setupList()
            case .tile:
                self.setupTiles()
            }
        }).disposed(by: disposeBag)
        
        // provide the cell size from delegate method
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Track.self)
            .bind(to: viewModel.openTrackAction.inputs)
            .disposed(by: disposeBag)
    }
    
    private func setupList() {
        collectionDisposeBag = DisposeBag()
        
        viewModel.tracks
            .bind(to: collectionView.rx.items(cellIdentifier: String(describing: TrackListCell.self), cellType: TrackListCell.self)) {
                (row, track, cell) in
                cell.titleLabel.text = track.title
            }
            .disposed(by: collectionDisposeBag)
    }

    private func setupTiles() {
        collectionDisposeBag = DisposeBag()
        
        viewModel.tracks
            .bind(to: collectionView.rx.items(cellIdentifier: String(describing: TrackTileCell.self), cellType: TrackTileCell.self)) { (row, track, cell) in
                cell.imageView.backgroundColor = .red
                _ = cell.disposeBag.insert(track.image
                    .startWith(#imageLiteral(resourceName: "no_track"))
                    .catchErrorJustReturn(#imageLiteral(resourceName: "no_track"))
                    .bind(to: cell.imageView.rx.image) )
                
            }.disposed(by: collectionDisposeBag)
    }
    
    private func setupToolbar() {
        listButton.rx.action = viewModel.listAction
        tileButton.rx.action = viewModel.tileAction
    }

}

extension TracksViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width
        var cellWidth: CGFloat = width
        var cellHeight: CGFloat = 44

        if viewModel.trackStyle.value == .tile {
            cellWidth = (width - 30) / 3 // compute your cell width
            cellHeight = cellWidth
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = collectionView.cellForItem(at: indexPath)
    }
}

