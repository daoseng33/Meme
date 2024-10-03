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
    
    private let timeStatusRelay = BehaviorRelay<AVPlayer.TimeControlStatus>(value: .paused)
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
        indicator.translatesAutoresizingMaskIntoConstraints = false
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
        player.rx.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, status) in
                self.timeStatusRelay.accept(status)
                
                switch status {
                case .paused:
                    if self.currentItem != nil {
                        self.playImageView.isHidden = false
                    }
                    
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
    func loadVideo(from url: URL) {
        showLoading()
        playImageView.isHidden = true
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        observePlayerItemStatus(item)
        
        playerLooper?.disableLooping()
        playerLooper = nil
        
        if let currentItem = currentItem {
            player.remove(currentItem)
        }
        
        currentItem = item
        player.insert(item, after: nil)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        player.play()
    }
    
    private func observePlayerItemStatus(_ item: AVPlayerItem) {
        item.rx.observe(AVPlayerItem.Status.self, #keyPath(AVPlayerItem.status))
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, status) in
                self.hideLoading()
                self.handlePlayerItemStatus(status)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .failed:
            self.handleErrorRelay.accept(())
            print("Video failed to load")
            
        default:
            break
        }
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func reset() {
        player.pause()
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
