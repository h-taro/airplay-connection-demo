//
//  ViewController.swift
//  demo
//
//  Created by taro.hiraishi on 2023/06/05.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("[debug] \(error.localizedDescription)")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        let videoURL = URL(string: "https://www.home-movie.biz/mov/hts-samp001.mp4")!
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player.play()
        
        setupAirPlay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else { return }
        
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.airPlay {
                print("[debug] AirPlay is connected")
            }
            
        case .oldDeviceUnavailable:
            if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.airPlay {
                    print("[debug] AirPlay has disconnected")
                }
            }
            
        default: break
        }
    }
    
    private func setupAirPlay() {
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.showsVolumeSlider = false
        volumeView.showsRouteButton = true
        volumeView.translatesAutoresizingMaskIntoConstraints = false
        volumeView.backgroundColor = .blue
        
        view.addSubview(volumeView)
        
        NSLayoutConstraint.activate([
            volumeView.widthAnchor.constraint(equalToConstant: 44),
            volumeView.heightAnchor.constraint(equalToConstant: 44),
            volumeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            volumeView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])
    }
}

