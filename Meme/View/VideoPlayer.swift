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

final class VideoPlayerView: UIView {
    // MARK: - Properties
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private let player = AVQueuePlayer()
    
    private let statusRelay = BehaviorRelay<AVPlayer.TimeControlStatus>(value: .paused)
    var status: AVPlayer.TimeControlStatus {
        return statusRelay.value
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
    }
    
    private func setupBindings() {
        player.rx.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
            .compactMap { $0 }
            .bind(to: statusRelay)
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Video player
    func loadVideo(from url: URL) {
        showLoading()
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        observePlayerItemStatus(item)
        
        player.replaceCurrentItem(with: item)
        
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
        player.replaceCurrentItem(with: nil)
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
