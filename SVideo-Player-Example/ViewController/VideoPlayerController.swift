//
//  VideoPlayerController.swift
//  SVideo-Player-Example
//
//  Created by Sparkout on 15/06/23.
//

import UIKit
import AVFoundation

protocol PlayerKitDelegate: AnyObject {
    func player(_ player: AVPlayer, _ state: AVPlayer.TimeControlStatus)
}

public final class PlayerKit {
    static let shared: PlayerKit = .init()
    let player: AVPlayer = .init()
    var playerState: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
    var delegate: PlayerKitDelegate?
    private init() {}
    
    // MARK: Controls
    @objc func playPause() {
        if case .playing = player.timeControlStatus {
            player.pause()
        } else if case .paused = player.timeControlStatus {
            player.play()
        }
        playerState = player.timeControlStatus
        delegate?.player(player, playerState)
    }
    
    @objc func play(url: String) {
        if let videoURL = URL(string: url) {
            let playerItem = AVPlayerItem(url: videoURL)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            playerState = player.timeControlStatus
            delegate?.player(player, playerState)
        }
    }
    
    @objc func next() {}
    
    @objc func previous() {}
    
}

class VideoPlayerController: UIViewController {
    private let playerKit: PlayerKit = .shared
    private lazy var videoLayer = AVPlayerLayer(player: playerKit.player)
    // MARK: Control Button Outlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var controlButtonContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        playerKit.play(url: "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_30mb.mp4")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLayer.frame = self.view.layer.frame
    }
    
    private func configureView() {
        playerKit.delegate = self
        NotificationCenter.default.addObserver(playerKit, selector:#selector(playerKit.playPause),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        videoLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        self.view.isUserInteractionEnabled = true
        // Tap gesture for video player
        let tapgestureForVideoPlayer = UITapGestureRecognizer(target: self, action: #selector(didTapVideoPlayer))
        self.view.addGestureRecognizer(tapgestureForVideoPlayer)
        
        controlButtonContainerView.isUserInteractionEnabled = true
        let tapgestureForControlView = UITapGestureRecognizer(target: self, action: #selector(didTapControlView))
        controlButtonContainerView.addGestureRecognizer(tapgestureForControlView)
        controlButtonContainerView.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.bringSubviewToFront(controlButtonContainerView)
        configureControlButtons()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showContainer(false)
        }
    }
    
    private func configureControlButtons() {
        nextButton.addTarget(playerKit, action: #selector(playerKit.next), for: .touchUpInside)
        previousButton.addTarget(playerKit, action: #selector(playerKit.previous), for: .touchUpInside)
        playPauseButton.addTarget(playerKit, action: #selector(playerKit.playPause), for: .touchUpInside)
    }
    
    @objc private func didTapVideoPlayer() {
        showContainer(true, animated: false)
    }
    
    @objc private func didTapControlView() {
        showContainer(false, animated: false)
    }
    
    private func showContainer(_ show: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 1 : 0, delay: 0) {[weak self] in
            self?.controlButtonContainerView.alpha = show ? 1.0 : 0.0
        }
    }
}

extension VideoPlayerController: PlayerKitDelegate {
    func player(_ player: AVPlayer, _ state: AVPlayer.TimeControlStatus) {
        let stateIcon = (state == .paused ? "play_01" : "pause_01")
        playPauseButton.setImage(UIImage(named: stateIcon), for: .normal)
    }
}
