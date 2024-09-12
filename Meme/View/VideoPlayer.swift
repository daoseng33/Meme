//
//  VideoPlayer.swift
//  Meme
//
//  Created by DAO on 2024/9/12.
//

import AVFoundation
import UIKit

class VideoPlayerView: UIView {
    // MARK: - Properties
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private let player = AVQueuePlayer()
    
    var status: AVPlayer.TimeControlStatus {
        return player.timeControlStatus
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
    
    // MARK: - Setup
    private func setupView() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer!)
        
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
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
        
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        
        player.replaceCurrentItem(with: item)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        player.play()
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func reset() {
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
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                hideLoading()
                
            case .failed:
                hideLoading()
                print("Video failed to load")
                
            case .unknown:
                break
                
            @unknown default:
                break
            }
        }
    }
}
