import UIKit
import FlowplayerSDK
import MediaPlayer

//MARK: - VideoPlayerView Delegate

protocol FlowVideoPlayerViewDelegate: AnyObject {
    func flowPlayerVideoPlayStatusChanged(isPlaying: Bool)
}

class FlowPlayerView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var flowPlayerView: FlowplayerView!
    
    var parentView: VideoPlayerContainerView!
    weak var delegate: FlowVideoPlayerViewDelegate?
    var videoDataObject: VideoDetail?
    // MARK: - View Initialize Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.initialConfig()
    }
    
    func initialConfig() {
        Bundle.main.loadNibNamed("FlowPlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
    // MARK: - Helper Functions
    
    func initializeFlowPlayer(for url: URL, video_id: VideoDetail) {
        self.flowPlayerView.autoPlay = true
        self.flowPlayerView.delegate = self
        self.flowPlayerView.adDelegate = self
        self.flowPlayerView.viewDelegate = self
        self.flowPlayerView.backgroundColor = .black
        self.flowPlayerView.enableBackgroundPlayback = false
        
        let configBuilder = ControlsConfig.create()
        configBuilder.setMuteControl(true)
        configBuilder.enablePlugins(["speed", "asel", "subtitles"])
        configBuilder.setCustom(key: "speed.options", value: [0.5, 1.0, 2.0])
        configBuilder.setCustom(key: "speed.labels", value: ["Slow", "Normal", "Fast"])
        self.flowPlayerView.controlsConfig = configBuilder.build()
        
        let video_Id = video_id.video_id ?? ""
        print("videoId", video_Id)
        
        let media_url = MediaExternal(url: url)
        self.flowPlayerView.load(external: media_url)
    }
    
    // Play Pause Button Action
    func playPauseButtonAction() {
        guard let player = flowPlayerView else { return }
        
        if player.state == .play {
            player.pause()
            delegate?.flowPlayerVideoPlayStatusChanged(isPlaying: false)
        }
        else if player.state == .pause {
            player.play()
            delegate?.flowPlayerVideoPlayStatusChanged(isPlaying: true)
        }
    }
    
    func cleanUpPlayerForReuse() {
        guard let player = flowPlayerView else { return }
        if player.state == .play {
            player.stop()
            delegate?.flowPlayerVideoPlayStatusChanged(isPlaying: false)
        }
    }
}
extension FlowPlayerView: FlowplayerViewDelegate {
    func view(_ view: FlowplayerViewAPI, didChangeViewVisibility isVisible: Bool) {
        print("Flowplayer became visible:", isVisible)
    }
}

// MARK: - FlowplayerAdDelegate
extension FlowPlayerView: FlowplayerAdDelegate {
    func player(_: FlowplayerAPI, didAdFailWith error: AdError) {
        print("Ad failed with error: \(error)")
    }
    
    func player(_: FlowplayerAPI, didChangeAdState state: AdState, for adType: AdType) {
        print("Ad of type: \(adType) changed state: \(state)")
    }
}

// MARK: - FlowplayerDelegate

extension FlowPlayerView: FlowplayerDelegate {
    func player(_ player: FlowplayerAPI, didChangeState state: PlayerState) {
        print("Player did change the state:", state)
    }
    
    func player(_ player: FlowplayerAPI, didChangePlaybackState state: PlaybackState) {
        print("Playback state did change:", state)
        
        // Current state is .playing and previous state is .background
        let wasInBackground = player.playbackStateList.prefix(2) == [
            .playing,
            
        ]
        
        /// If player was paused continue playback from the background
        if wasInBackground && player.state == .pause {
            player.play()
        }
    }
}
