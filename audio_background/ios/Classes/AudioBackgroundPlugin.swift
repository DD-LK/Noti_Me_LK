import Flutter
import UIKit
import AVFoundation

public class AudioBackgroundPlugin: NSObject, FlutterPlugin {
    private var player: AVPlayer?
    private var channel: FlutterMethodChannel
    private var timeObserverToken: Any?

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.audio_background", binaryMessenger: registrar.messenger())
        let instance = AudioBackgroundPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "play":
            guard let args = call.arguments as? [String: Any],
                  let urlString = args["url"] as? String,
                  let url = URL(string: urlString) else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            
            setupAudioSession()
            
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            
            addObservers()
            
            result(nil)
        case "pause":
            player?.pause()
            result(nil)
        case "stop":
            player?.pause()
            player = nil
            removeObservers()
            result(nil)
        case "seek":
            guard let args = call.arguments as? [String: Any],
                  let position = args["position"] as? Int else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            let time = CMTime(milliseconds: position)
            player?.seek(to: time)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    private func addObservers() {
        guard let player = player else { return }
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.channel.invokeMethod("onPositionChanged", arguments: time.toMilliseconds())
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    private func removeObservers() {
        guard let player = player else { return }
        
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        player.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        channel.invokeMethod("onStateChanged", arguments: 3) // completed
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate", let player = player {
            let state = player.rate > 0 ? 2 : 1 // playing or paused
            channel.invokeMethod("onStateChanged", arguments: state)
        }
    }
}

extension CMTime {
    func toMilliseconds() -> Int {
        return Int(CMTimeGetSeconds(self) * 1000)
    }
}

extension CMTime {
    init(milliseconds: Int) {
        self.init(seconds: Double(milliseconds) / 1000, preferredTimescale: 1000)
    }
}