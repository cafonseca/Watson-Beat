//
//  WatsonMusic.swift
//  Watson-Beat
//
//  Created by fonseca on 11/11/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Foundation
import AudioKit
import CoreMIDI

protocol WatsonMusicDelegate: AnyObject {
    func midiInstrumentCallbackMessage(status: UInt8,
                                       noteNumber: MIDINoteNumber,
                                       velocity: MIDIVelocity,
                                       channel: UInt8,
                                       message: String)
}

class WatsonMusic {
    var watsonMusicDelegate:WatsonMusicDelegate?
    private var sequencer:AKSequencer!
    private var midiOut:AKMIDI!
    private var inspirationMidiFilename:String?
    private var iniParametersFilename:String?
    private var outputDirectory:String!
    
    private var callbackInstrument0:AKMIDICallbackInstrument!
    private var callbackInstrument1:AKMIDICallbackInstrument!
    private var callbackInstrument2:AKMIDICallbackInstrument!
    private var callbackInstrument3:AKMIDICallbackInstrument!
    private var callbackInstrument4:AKMIDICallbackInstrument!
    private var callbackInstrument5:AKMIDICallbackInstrument!
    private var callbackInstrument6:AKMIDICallbackInstrument!
    private var callbackInstrument7:AKMIDICallbackInstrument!
    private var callbackInstrument8:AKMIDICallbackInstrument!
    private var callbackInstrument9:AKMIDICallbackInstrument!
    private var callbackInstrument10:AKMIDICallbackInstrument!
    private var callbackInstrument11:AKMIDICallbackInstrument!
    private var callbackInstrument12:AKMIDICallbackInstrument!
    private var callbackInstrument13:AKMIDICallbackInstrument!
    private var callbackInstrument14:AKMIDICallbackInstrument!
    
    private static var sharedWatsonMusic: WatsonMusic = {
        let watsonMusic = WatsonMusic()
        return watsonMusic
    }()
    
    private init() {
        initializeAudio()
        iniParametersFilename = "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/Ini/Inspire.ini"
        inspirationMidiFilename = "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/Midi/ode_to_joy2.mid"
        outputDirectory = "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/output2"
    }
    
    class func shared() -> WatsonMusic {
        return sharedWatsonMusic
    }
    
    private func initializeAudio() {
        midiOut = AudioKit.midi
        midiOut.openInput(midiOut.inputNames[0])
        print("Opening ouput \(midiOut.destinationNames[0])")
        midiOut.openOutput(midiOut.destinationNames[0])
        print("Output = \(midiOut.outputPort)")
        do {
            try AudioKit.start()
        } catch {
            print("Error initializing Audiokit: \(error)")
        }
    }
    
    func getMidi() -> AKMIDI {
        return midiOut
    }
    
    func setInspirationMidiFilename(_ filename: String) {
        inspirationMidiFilename = filename
    }

    func getIniParametersFilename() -> String? {
        return iniParametersFilename
    }

    func setIniParametersFilename(_ filename: String) {
        iniParametersFilename = filename
    }
    
    func getInspirationMidiFilename() -> String? {
        return inspirationMidiFilename
    }

    func setOutpuDirectory(_ directory: String) {
        outputDirectory = directory
    }
    
    func getOutputDirectory() -> String? {
        return outputDirectory
    }

    func StopAndReset() {
        if sequencer != nil && sequencer.isPlaying {
            sequencer.stop()
        }
        
        let channels:Array<UInt8> = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
        for chan in channels {
            var event = AKMIDIEvent(controllerChange: 120, value: 0, channel: chan)
            midiOut.sendEvent(event)
            event = AKMIDIEvent(controllerChange: 121, value: 0, channel: chan)
            midiOut.sendEvent(event)
            event = AKMIDIEvent(controllerChange: 123, value: 0, channel: chan)
            midiOut.sendEvent(event)
            event = AKMIDIEvent(controllerChange: 127, value: 0, channel: chan)
            midiOut.sendEvent(event)
        }

    }
    
    private func getTrack(forFileName filename:String) -> AKMusicTrack? {
        var track:AKMusicTrack?
        if filename.lowercased().contains("piano1") {
            track = sequencer.tracks[0]
        } else if filename.lowercased().contains("bass") {
            track = sequencer.tracks[1]
        } else if filename.lowercased().contains("lostrings") {
            track = sequencer.tracks[2]
        } else if filename.lowercased().contains("mistrings") {
            track = sequencer.tracks[3]
        } else if filename.lowercased().contains("histrings") {
            track = sequencer.tracks[4]
        } else if filename.lowercased().contains("arpstrings") {
            track = sequencer.tracks[5]
        } else if filename.lowercased().contains("bassrhythms") {
            track = sequencer.tracks[6]
        } else if filename.lowercased().contains("rhythmchords") {
            track = sequencer.tracks[7]
        } else if filename.lowercased().contains("mel") {
            track = sequencer.tracks[8]
        } else if filename.lowercased().contains("drumskit") {
            track = sequencer.tracks[9]
        } else if filename.lowercased().contains("fills") {
            track = sequencer.tracks[10]
        } else if filename.lowercased().contains("drumslatin") {
            track = sequencer.tracks[11]
        } else if filename.lowercased().contains("drumsbass") {
            track = sequencer.tracks[12]
        } else if filename.lowercased().contains("piano2") {
            track = sequencer.tracks[13]
        } else if filename.lowercased().contains("piano") {
            track = sequencer.tracks[14]
        } else {
            print("No track for filename: \(filename)")
        }
        return track
    }
    
    func play(midiFile filename:String) {
        StopAndReset()
        sequencer = AKSequencer(fromURL: URL(fileURLWithPath: filename))
        callbackInstrument0 = AKMIDICallbackInstrument()
        sequencer.tracks[0].setMIDIOutput(callbackInstrument0.midiIn)
        callbackInstrument0.callback = callbackInstrument0_callback
        print("Playing MIDI file")
        sequencer.enableLooping()
        sequencer.play()
    }
    
    func play() {
        self.play(filesInDirectory: outputDirectory, andLoop: false)
    }
    
    func play(andLoop loop:Bool) {
        self.play(filesInDirectory: outputDirectory, andLoop: loop)
    }
    
    func play(filesInDirectory path: String, andLoop loop:Bool) {
        StopAndReset()
        sequencer = AKSequencer()               // Channel
        _ = sequencer.newTrack("Piano1")         // 1
        _ = sequencer.newTrack("Bass")          // 2
        _ = sequencer.newTrack("LoStrings")     // 3
        _ = sequencer.newTrack("MidStrings")    // 4
        _ = sequencer.newTrack("HiStrings")     // 5
        _ = sequencer.newTrack("ArpStrings")    // 6
        _ = sequencer.newTrack("BassRhythms")   // 7
        _ = sequencer.newTrack("RhythmChords")  // 8
        _ = sequencer.newTrack("Melody")        // 9
        _ = sequencer.newTrack("Drums")         // 10
        _ = sequencer.newTrack("DrumFills")     // 11
        _ = sequencer.newTrack("DrumsLatinPop") // 12
        _ = sequencer.newTrack("DrumsBass")     // 13
        _ = sequencer.newTrack("Piano2")        // 14
        _ = sequencer.newTrack("Piano")         // 15
        
        print("Number of tracks \(sequencer.tracks.count)")
        
        callbackInstrument0 = AKMIDICallbackInstrument()
        sequencer.tracks[0].setMIDIOutput(callbackInstrument0.midiIn)
        callbackInstrument0.callback = callbackInstrument0_callback
        
        callbackInstrument1 = AKMIDICallbackInstrument()
        sequencer.tracks[1].setMIDIOutput(callbackInstrument1.midiIn)
        callbackInstrument1.callback = callbackInstrument1_callback
        
        callbackInstrument2 = AKMIDICallbackInstrument()
        sequencer.tracks[2].setMIDIOutput(callbackInstrument2.midiIn)
        callbackInstrument2.callback = callbackInstrument2_callback

        callbackInstrument3 = AKMIDICallbackInstrument()
        sequencer.tracks[3].setMIDIOutput(callbackInstrument3.midiIn)
        callbackInstrument3.callback = callbackInstrument3_callback

        callbackInstrument4 = AKMIDICallbackInstrument()
        sequencer.tracks[4].setMIDIOutput(callbackInstrument4.midiIn)
        callbackInstrument4.callback = callbackInstrument4_callback

        callbackInstrument5 = AKMIDICallbackInstrument()
        sequencer.tracks[5].setMIDIOutput(callbackInstrument5.midiIn)
        callbackInstrument5.callback = callbackInstrument5_callback

        callbackInstrument6 = AKMIDICallbackInstrument()
        sequencer.tracks[6].setMIDIOutput(callbackInstrument6.midiIn)
        callbackInstrument6.callback = callbackInstrument6_callback

        callbackInstrument7 = AKMIDICallbackInstrument()
        sequencer.tracks[7].setMIDIOutput(callbackInstrument7.midiIn)
        callbackInstrument7.callback = callbackInstrument7_callback

        callbackInstrument8 = AKMIDICallbackInstrument()
        sequencer.tracks[8].setMIDIOutput(callbackInstrument8.midiIn)
        callbackInstrument8.callback = callbackInstrument8_callback

        callbackInstrument9 = AKMIDICallbackInstrument()
        sequencer.tracks[9].setMIDIOutput(callbackInstrument9.midiIn)
        callbackInstrument9.callback = callbackInstrument9_callback

        callbackInstrument10 = AKMIDICallbackInstrument()
        sequencer.tracks[10].setMIDIOutput(callbackInstrument10.midiIn)
        callbackInstrument10.callback = callbackInstrument10_callback

        callbackInstrument11 = AKMIDICallbackInstrument()
        sequencer.tracks[11].setMIDIOutput(callbackInstrument11.midiIn)
        callbackInstrument11.callback = callbackInstrument11_callback

        callbackInstrument12 = AKMIDICallbackInstrument()
        sequencer.tracks[12].setMIDIOutput(callbackInstrument12.midiIn)
        callbackInstrument12.callback = callbackInstrument12_callback
        
        callbackInstrument13 = AKMIDICallbackInstrument()
        sequencer.tracks[13].setMIDIOutput(callbackInstrument13.midiIn)
        callbackInstrument13.callback = callbackInstrument13_callback
        
        callbackInstrument14 = AKMIDICallbackInstrument()
        sequencer.tracks[14].setMIDIOutput(callbackInstrument14.midiIn)
        callbackInstrument14.callback = callbackInstrument14_callback
        
        let fileNames = try! FileManager.default.contentsOfDirectory(atPath: path)
        for filename in fileNames {
            if filename.contains(".mid") == true && filename.contains("notation") == false {
                //print(path + "/" + filename)
                let track = getTrack(forFileName: filename)
                if track != nil {
                    let s = AKSequencer(fromURL: URL(fileURLWithPath: path + "/" + filename))
                    //print("Number of tracks \(s.tracks.count)")
                    if s.tracks.count > 0 {
                        let lastTrack = s.tracks[0]
                        //print("lastTrack items \(lastTrack.getMIDINoteData().count)")
                        lastTrack.copyAndMergeTo(musicTrack: track!)
                        //print("track items \(track!.getMIDINoteData().count)")
                    }
                }
            }
        }
        print("Playing")
        if loop == true {
            sequencer.enableLooping()
        }
        sequencer.play()
    }
    
    private func callbackInstrument0_callback(_ status: UInt8,
                                    _ noteNumber: MIDINoteNumber,
                                    _ velocity: MIDIVelocity) {
        
        print("Chan 0 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 0, message: "Channel: 0, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument1_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 1 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 1, message: "Channel: 1, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(1))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(1))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument2_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 2 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
       
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 2, message: "Channel: 2, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(2))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(2))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument3_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 3 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 3, message: "Channel: 3, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(3))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(3))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument4_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 4 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 4, message: "Channel: 4, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(4))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(4))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument5_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 5 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 5, message: "Channel: 5, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(5))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(5))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument6_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 6 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 6, message: "Channel: 6, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(6))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(6))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument7_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 7 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 7, message: "Channel: 7, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(7))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(7))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument8_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 8 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 8, message: "Channel: 8, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(8))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(8))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument9_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 9 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 9, message: "Channel: 9, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(9))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(9))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument10_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 10 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 10, message: "Channel: 10, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(10))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(10))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument11_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 11 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 11, message: "Channel: 11, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(11))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(11))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument12_callback(_ status: UInt8,
                                      _ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        
        print("Chan 12 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 12, message: "Channel: 12, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(12))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            //let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(12))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument13_callback(_ status: UInt8,
                                               _ noteNumber: MIDINoteNumber,
                                               _ velocity: MIDIVelocity) {
        
        print("Chan 13 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 13, message: "Channel: 13, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(13))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            //let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(13))
            midiOut.sendEvent(event)
        }
    }
    
    private func callbackInstrument14_callback(_ status: UInt8,
                                               _ noteNumber: MIDINoteNumber,
                                               _ velocity: MIDIVelocity) {
        
        print("Chan 14 time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if watsonMusicDelegate != nil {
            watsonMusicDelegate?.midiInstrumentCallbackMessage(status: status, noteNumber: noteNumber, velocity: velocity, channel: 14, message: "Channel: 14, Time: \(sequencer.currentPosition.beats), Status: \(status), Note Number: \(noteNumber), Velocity: \(velocity)")
        }
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(14))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            //let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(14))
            midiOut.sendEvent(event)
        }
    }
}
