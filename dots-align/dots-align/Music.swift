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
    var audioPlayer: AVAudioPlayer?
    var songPlaying: String = ""
    
    func play(song: String) {
        if song == self.songPlaying {
            return // same song, let it continue
        }
        
        if (audioPlayer != nil) {
            self.stop()
        }
        
        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: song, ofType: "m4a")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:aSound as URL)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
            self.songPlaying = song
        } catch {
            print("Cannot play the file")
        }
    }
    
    func stop(fadeDuration: TimeInterval = 0.5) {
        audioPlayer!.setVolume(0, fadeDuration: fadeDuration)
        audioPlayer!.stop()
        self.songPlaying = ""
    }
}
