//
//  VideoPlayViewController.swift
//  BMPlayer
//
//  Created by BrikerMan on 16/4/28.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import BMPlayer
import AVFoundation
import NVActivityIndicatorView

func delay(_ seconds: Double, completion:@escaping ()->()) {
  let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
  
  DispatchQueue.main.asyncAfter(deadline: popTime) {
    completion()
  }
}

class VideoPlayViewController: UIViewController {
  
  //    @IBOutlet weak var player: BMPlayer!
  
  var player: BMPlayer!
  
  var index: IndexPath!
  
  var changeButton = UIButton()
    
  var playerTopConstraint: NSLayoutConstraint!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPlayerManager()
    preparePlayer()
    setupPlayerResource()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationDidEnterBackground),
                                           name: NSNotification.Name.UIApplicationDidEnterBackground,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationWillEnterForeground),
                                           name: NSNotification.Name.UIApplicationWillEnterForeground,
                                           object: nil)
  }
  
  @objc func applicationWillEnterForeground() {
    
  }
  
  @objc func applicationDidEnterBackground() {
    player.pause(allowAutoPlay: false)
  }
  
  /**
   prepare playerView
   */
  func preparePlayer() {
    var controller: BMPlayerControlView? = nil
    
    if index.row == 0 && index.section == 2 {
      controller = BMPlayerCustomControlView()
    }
    
    if index.row == 1 && index.section == 2 {
      controller = BMPlayerCustomControlView2()
    }
    
    player = BMPlayer(customControlView: controller)
    player.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(player)
    if #available(iOS 11.0, *) {
        player.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 9/16).isActive = true
        playerTopConstraint = player.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        playerTopConstraint.isActive = true
        player.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        player.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    } else {
        if #available(iOS 9.0, *) {
            player.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            player.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            player.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            player.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        } else {
            print("This pod does not support below iOS 9.0")
        }
    }
    
    player.delegate = self
    player.backBlock = { [unowned self] (isFullScreen) in
      if isFullScreen {
        return
      } else {
        let _ = self.navigationController?.popViewController(animated: true)
      }
    }
    
    changeButton.setTitle("Change Video", for: .normal)
    changeButton.addTarget(self, action: #selector(onChangeVideoButtonPressed), for: .touchUpInside)
    changeButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
    view.addSubview(changeButton)
    changeButton.translatesAutoresizingMaskIntoConstraints = false
    if #available(iOS 9.0, *) {
        changeButton.topAnchor.constraint(equalTo: player.bottomAnchor, constant: 30).isActive = true
        changeButton.leadingAnchor.constraint(equalTo: player.leadingAnchor, constant: 10).isActive = true
    } else {
        print("This pod does not support below iOS 9")
    }
    changeButton.isHidden = true
    self.view.layoutIfNeeded()
  }
  
  @objc fileprivate func onChangeVideoButtonPressed() {
    let urls = ["http://us-west-1-cdn.indi.com/Zencoder/z3_0/a88dbdd7d5236918df5c5d358d676b38/video-0480p-1088k.mp4",
                "http://us-west-1-cdn.indi.com/Zencoder/z3_0/a88dbdd7d5236918df5c5d358d676b38/video-0480p-1088k.mp4",
                "http://us-west-1-cdn.indi.com/Zencoder/z3_0/a88dbdd7d5236918df5c5d358d676b38/video-0480p-1088k.mp4"]
    let random = Int(arc4random_uniform(UInt32(urls.count)))
    let asset = BMPlayerResource(url: URL(string: urls[random])!, name: "Video @\(random)")
    player.setVideo(resource: asset)
  }
  
  
  func setupPlayerResource() {
    switch (index.section,index.row) {
      
    case (0,0):
      let str = Bundle.main.url(forResource: "SubtitleDemo", withExtension: "srt")!
      let url = URL(string: "http://us-west-1-cdn.indi.com/Zencoder/z3_0/a88dbdd7d5236918df5c5d358d676b38/video-0480p-1088k.mp4")!
      
      let subtitle = BMSubtitles(url: str)
      
      let asset = BMPlayerResource(name: "Video Name Here",
                                   definitions: [BMPlayerResourceDefinition(url: url, definition: "480p")],
                                   cover: nil,
                                   subtitles: subtitle)
      
      // How to change subtiles
      //            delay(5, completion: {
      //                if let resource = self.player.currentResource {
      //                    resource.subtitle = nil
      //                    self.player.forceReloadSubtile()
      //                }
      //            })
      //
      //            delay(10, completion: {
      //                if let resource = self.player.currentResource {
      //                    resource.subtitle = BMSubtitles(url: Bundle.main.url(forResource: "SubtitleDemo2", withExtension: "srt")!)
      //                }
      //            })
      //
      //
      //            // How to change get current uel
      //            delay(5, completion: {
      //                if let resource = self.player.currentResource {
      //                    for i in resource.definitions {
      //                        print("video \(i.definition) url is \(i.url)")
      //                    }
      //                }
      //            })
      //
      player.seek(30)
      player.setVideo(resource: asset)
      changeButton.isHidden = false
      
    case (0,1):
      let asset = self.preparePlayerItem()
      player.setVideo(resource: asset)
      
    case (0,2):
      let asset = self.preparePlayerItem()
      player.setVideo(resource: asset)
      
    case (2,0):
      player.panGesture.isEnabled = false
      let asset = self.preparePlayerItem()
      player.setVideo(resource: asset)
      
    case (2,1):
      player.videoGravity = AVLayerVideoGravity.resizeAspect
      let asset = BMPlayerResource(url: URL(string: "http://baobab.wdjcdn.com/14525705791193.mp4")!, name: "风格互换：原来你我相爱")
      player.setVideo(resource: asset)
      
    default:
      let asset = self.preparePlayerItem()
      player.setVideo(resource: asset)
    }
  }
  
  // 设置播放器单例，修改属性
  func setupPlayerManager() {
    resetPlayerManager()
    switch (index.section,index.row) {
    // 普通播放器
    case (0,0):
      break
    case (0,1):
      break
    case (0,2):
      // 设置播放器属性，此情况下若提供了cover则先展示封面图，否则黑屏。点击播放后开始loading
      BMPlayerConf.shouldAutoPlay = false
      
    case (1,0):
      // 设置播放器属性，此情况下若提供了cover则先展示封面图，否则黑屏。点击播放后开始loading
      BMPlayerConf.topBarShowInCase = .always
      
      
    case (1,1):
      BMPlayerConf.topBarShowInCase = .horizantalOnly
      
      
    case (1,2):
      BMPlayerConf.topBarShowInCase = .none
      
    case (1,3):
      BMPlayerConf.tintColor = UIColor.red
      
    default:
      break
    }
  }
  
  
  /**
   准备播放器资源model
   */
  func preparePlayerItem() -> BMPlayerResource {
    let res0 = BMPlayerResourceDefinition(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                          definition: "高清")
    let res1 = BMPlayerResourceDefinition(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                          definition: "标清")
    
    let asset = BMPlayerResource(name: "周末号外丨中国第一高楼",
                                 definitions: [res0, res1],
                                 cover: URL(string: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg"))
    return asset
  }
  
  
  func resetPlayerManager() {
    BMPlayerConf.allowLog = false
    BMPlayerConf.shouldAutoPlay = true
    BMPlayerConf.tintColor = UIColor.white
    BMPlayerConf.topBarShowInCase = .always
    BMPlayerConf.loaderType  = NVActivityIndicatorType.ballRotateChase
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    // If use the slide to back, remember to call this method
    // 使用手势返回的时候，调用下面方法
    player.pause(allowAutoPlay: true)
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
    // If use the slide to back, remember to call this method
    // 使用手势返回的时候，调用下面方法
    player.autoPlay()
  }
  
  deinit {
    // If use the slide to back, remember to call this method
    // 使用手势返回的时候，调用下面方法手动销毁
    player.prepareToDealloc()
    print("VideoPlayViewController Deinit")
  }
  
}

// MARK:- BMPlayerDelegate example
extension VideoPlayViewController: BMPlayerDelegate {
  // Call when player orinet changed
  func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
    navigationController?.setNavigationBarHidden(isFullscreen, animated: true)
    playerTopConstraint.isActive = false
    if #available(iOS 9.0, *) {
        if isFullscreen {
            playerTopConstraint = player.topAnchor.constraint(equalTo: view.topAnchor)
            playerTopConstraint.isActive = true
        } else {
            if #available(iOS 11.0, *) {
                playerTopConstraint = player.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            } else {
                playerTopConstraint = player.topAnchor.constraint(equalTo: view.topAnchor)
            }
           playerTopConstraint.isActive = true
        }
    } else {
        print("Not allowed in < iOS 9.0")
    }
  }
  
  // Call back when playing state changed, use to detect is playing or not
  func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
    print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
  }
  
  // Call back when playing state changed, use to detect specefic state like buffering, bufferfinished
  func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
    print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
  }
  
  // Call back when play time change
  func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
    //        print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
  }
  
  // Call back when the video loaded duration changed
  func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
    //        print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
  }
}
