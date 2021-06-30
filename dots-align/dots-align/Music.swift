//
//  Music.swift
//  dots-align
//
//  Created by Jonathan on 2021-06-26.
//

import Foundation
import AVFoundation

class Music {
    static let instance = Music() // singleton
    var audioPlayerMenu: AVAudioPlayer?
    var audioPlayerGame: AVAudioPlayer?
    var audioPlayerBeep: AVAudioPlayer?
    var songPlaying: String = ""
    
    func playSong(_ name: String) {
        if name == self.songPlaying {
            return // same song, let it continue
        }
        
        // Using multiple players in order to crossfade and avoid glitch.
        self.stop(self.audioPlayerMenu)
        self.stop(self.audioPlayerGame)
        
        if name == Const.Music.game {
            self.audioPlayerGame = self.initPlayer(name)
        } else if name == Const.Music.menu {
            self.audioPlayerMenu = self.initPlayer(name)
        }
    }
    
    func playBeep(_ name: String) {
        let url = NSURL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "wav")!)
        do {
            audioPlayerBeep = try AVAudioPlayer(contentsOf:url as URL)
            audioPlayerBeep!.prepareToPlay()
            audioPlayerBeep!.play()
        } catch {
            print("Cannot play the file")
        }
    }
    
    func stop(_ player: AVAudioPlayer?, fadeDuration: TimeInterval = 0.2) {
        player?.setVolume(0, fadeDuration: fadeDuration)
        // Not stopping the player, as it overrides the fadeout.
    }
    
    private func initPlayer(_ name: String) -> AVAudioPlayer? {
        var player: AVAudioPlayer? = nil
        
        do {
            let url = NSURL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "m4a")!)
            player = try AVAudioPlayer(contentsOf:url as URL)
            player!.numberOfLoops = -1
            player!.prepareToPlay()
            player!.play()
            
            self.songPlaying = name
        } catch {
            print("Cannot play the file")
        }
        
        return player
    }
}
