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
    var audioPlayerSong: AVAudioPlayer?
    var audioPlayerBeep: AVAudioPlayer?
    var songPlaying: String = ""
    
    func playSong(_ name: String) {
        if name == self.songPlaying {
            return // same song, let it continue
        }
        
        let url = NSURL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "m4a")!)
        do {
            audioPlayerSong = try AVAudioPlayer(contentsOf:url as URL)
            audioPlayerSong!.numberOfLoops = -1
            audioPlayerSong!.prepareToPlay()
            audioPlayerSong!.play()
            self.songPlaying = name
        } catch {
            print("Cannot play the file")
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
}
