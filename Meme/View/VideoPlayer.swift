//
//  VideoPlayer.swift
//  Meme
//
//  Created by DAO on 2024/9/12.
//

import AVFoundation
import UIKit
import RxSwift
import RxRelay
import SnapKit
import SFSafeSymbols

final class VideoPlayerView: UIView {
    // MARK: - Properties
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private let player = AVQueuePlayer()
    private var currentItem: AVPlayerItem?
    
    private let timeStatusRelay = BehaviorRelay<AVPlayer.TimeControlStatus>(value: .waitingToPlayAtSpecifiedRate)
    var timeStatus: AVPlayer.TimeControlStatus {
        timeStatusRelay.value
    }
    
    private let handleErrorRelay = PublishRelay<Void>()
    var handleErrorObservable: Observable<Void> {
        handleErrorRelay.asObservable()
    }
    
    // MARK: - UI
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGray
        return indicator
    }()
    
    private let playImageView: UIImageView = {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        let image = UIImage(systemSymbol: .playCircle, withConfiguration: symbolConfig).withRenderingMode(.alwaysOriginal).withTintColor(.accent)
        let imageView = UIImageView(image: image)
        imageView.isHidden = true
        
        // Add shadow effect
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 1
        imageView.layer.shadowOpacity = 0.5
        
        // Ensure shadow is visible if the image has transparent parts
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
        
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupView() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer!)
        
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        addSubview(playImageView)
        playImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        Observable.combineLatest(
                player.rx.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus)).compactMap { $0 },
                player.rx.observe(AVPlayerItem.Status.self, #keyPath(AVPlayer.currentItem.status)).compactMap { $0 }
            )
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, combined) in
                let (timeStatus, itemStatus) = combined
                
                self.timeStatusRelay.accept(timeStatus)
                
                switch (timeStatus, itemStatus) {
                case (.paused, .readyToPlay):
                    if self.currentItem != nil {
                        self.playImageView.isHidden = false
                    }
                    
                    self.hideLoading()
                    
                case (.playing, _):
                    self.playImageView.isHidden = true
                    
                case (_, .readyToPlay):
                    self.hideLoading()
                    
                case (_, .failed):
                    self.handleErrorRelay.accept(())
                    self.hideLoading()
                    
                default:
                    self.playImageView.isHidden = true
                }
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Video player
    func loadVideo(from url: URL, shouldAutoPlay: Bool = true) {
        showLoading()
        playImageView.isHidden = true
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        playerLooper?.disableLooping()
        playerLooper = nil
        
        if let currentItem = currentItem {
            player.remove(currentItem)
        }
        
        currentItem = item
        player.insert(item, after: nil)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        if shouldAutoPlay {
            player.play()
        }
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func reset() {
        playerLooper?.disableLooping()
        playerLooper = nil
        if let currentItem = currentItem {
            player.remove(currentItem)
        }
        currentItem = nil
        playImageView.isHidden = true
    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
}
