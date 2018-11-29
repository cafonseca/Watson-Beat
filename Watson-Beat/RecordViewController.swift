//
//  RecordViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/21/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa
import AudioKit

class MidiNote {
    var noteNumber:MIDINoteNumber!
    var velosity:MIDIVelocity!
    var duration:AKDuration!
    var position:AKDuration!
}

class RecordViewController: NSViewController, AKMIDIListener {
    var watsonBeatViewController:WatsonBeatViewController!
    private var isMetronomeOn = true
    private var notes:[String:MidiNote] = [:]
    private var beats = 16
    private var beatCounter = 1
    public var sequencer:AKSequencer!
    private var recordingTrack:AKMusicTrack!
    @IBOutlet var outputTextview: NSTextView!
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var tempotextField: NSTextField!
    @IBOutlet weak var beatsTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.        
    }
    
    private func record(_ flag:Bool) {
        if flag == true {
            recordButton.isEnabled = false
            stopButton.isEnabled = true
            playButton.isEnabled = false
            saveButton.isEnabled = false
            cancelButton.isEnabled = false
            beatCounter = 1
            isMetronomeOn = true

            sequencer = AKSequencer()
            var tempo = Double(tempotextField.stringValue)!
            if tempo < 40 || tempo > 180 {
                tempo = 60
                tempotextField.stringValue = String(60)
            }
            sequencer.setTempo(tempo)
            var b = Double(beatsTextField.stringValue)!
            beats = Int(b)
            if b < 4 || b > 100 {
                b = 16
                beats = Int(b)
                beatsTextField.stringValue = String(b)
            }
            sequencer.setLength(AKDuration(beats: Double(beats)))
            //sequencer.enableLooping(AKDuration(beats:Double(beats)))
            
            let metronomeCallbackInst = AKMIDICallbackInstrument()
            let metronomeTrack = sequencer.newTrack("metronome")
            metronomeTrack?.setMIDIOutput(metronomeCallbackInst.midiIn)
            
            recordingTrack = sequencer.newTrack("piano")
            
            // create the MIDI data
            for i in 0 ..< beats {
                metronomeTrack?.add(noteNumber: 60, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.5))
            }
            
            // set the callback
            metronomeCallbackInst.callback = {status, noteNumber, velocity in
                let midiOut = WatsonMusic.shared().getMidi()
                if status == 144 {
                    if self.isMetronomeOn == true {
                        let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(10))
                        midiOut.sendEvent(event)
                    }
                } else if status == 128 {
                    if self.isMetronomeOn == true {
                        let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(10))
                        midiOut.sendEvent(event)
                    }
                    self.beatCounter = self.beatCounter + 1
                    if self.beatCounter == self.beats {
                        DispatchQueue.main.async(execute: {
                            self.record(false)
                        })
                    }
                }
            }
            
            notes = [String:MidiNote]()
            WatsonMusic.shared().getMidi().addListener(self)
            sequencer.play()
        } else {
            recordButton.isEnabled = true
            stopButton.isEnabled = false
            playButton.isEnabled = true
            saveButton.isEnabled = true
            cancelButton.isEnabled = true
            sequencer.stop()
            WatsonMusic.shared().getMidi().clearListeners()
            if sequencer.tracks.count > 1 {
                print("Number of notes recorded \(sequencer.tracks[1].getMIDINoteData().count)")
            }
        }
    }
    
    @IBAction func recordAction(_ sender: NSButton) {
        record(true)
    }
    
    @IBAction func stopAction(_ sender: NSButton) {
        record(false)
    }
    
    @IBAction func playAction(_ sender: Any) {
        recordButton.isEnabled = false
        stopButton.isEnabled = true
        playButton.isEnabled = false
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
        beatCounter = 1
        isMetronomeOn = false

        let callbackInst = AKMIDICallbackInstrument()
        //sequencer.deleteTrack(trackIndex: 0)
        recordingTrack.setMIDIOutput(callbackInst.midiIn)
        // set the callback
        callbackInst.callback = {status, noteNumber, velocity in
//            print("Current time: \(self.sequencer.currentPosition.beats)")
//            print("Length: \(self.sequencer.length.beats)")
            print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")

            let midiOut = WatsonMusic.shared().getMidi()
            if status == 144 {
//                print("noteOn")
                let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
                midiOut.sendEvent(event)
            } else if status == 128 {
//                print("noteOff")
                let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(0))
                midiOut.sendEvent(event)
            }
            if self.sequencer.length == self.sequencer.currentPosition {
                DispatchQueue.main.async(execute: {
                    self.record(false)
                })
            }
        }
        
        sequencer.rewind()
        sequencer.play()
    }
    
    @IBAction func saveAction(_ sender: NSButton) {
        //(self.parent as! InspirationViewController).updateFilenameTextField("")
        self.view.window?.close()
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveFileSegue" {
            (segue.destinationController as? SaveInspirationFileViewController)?.recordViewController = self
            (segue.destinationController as? SaveInspirationFileViewController)?.watsonBeatViewController = watsonBeatViewController
            self.view.window?.close()
        }        
    }

    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) noteOn: \(noteNumber) velocity: \(velocity) ")
        if let note = notes[String(noteNumber)] {
            print("The note exists.  Note numeber: \(note.noteNumber)")
        } else {
            print("The note does not exist. Creating...")
            let newNote = MidiNote()
            newNote.noteNumber = noteNumber
            newNote.position = sequencer.currentPosition
            newNote.velosity = velocity
            notes[String(noteNumber)] = newNote
        }
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) noteOff: \(noteNumber) velocity: \(velocity) ")
        if let note = notes[String(noteNumber)] {
            print("The note exists.  Note numeber: \(note.noteNumber)")
            note.duration = sequencer.currentPosition - note.position
            let noteData = AKMIDINoteData(noteNumber: note.noteNumber, velocity: note.velosity, channel: 0, duration: note.duration, position: note.position)
            recordingTrack.add(midiNoteData: noteData)
            notes.removeValue(forKey: String(noteNumber))
        } else {
            print("The note does not exist.")
        }
    }
    
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) controller: \(controller) value: \(value) ")
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        updateText("Pitch Wheel on Channel: \(channel + 1) value: \(pitchWheelValue) ")
    }
    
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) midiAftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
    }
    
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) midiAfterTouch pressure: \(pressure) ")
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1)  midiPitchWheel: \(pitchWheelValue)")
    }
    
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) programChange: \(program)")
    }
    
    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        if let command = AKMIDISystemCommand(rawValue: data[0]) {
            var newString = "MIDI System Command: \(command) \n"
            for i in 0 ..< data.count {
                let hexValue = String(format: "%2X", data[i])
                newString.append("\(hexValue) ")
            }
            updateText(newString)
        }
        updateText("received \(data.count) bytes of data")
    }

    
    func updateText(_ input: String) {
        DispatchQueue.main.async(execute: {
            self.outputTextview.string = "\(input)\n\(self.outputTextview.string)"
        })
    }
}
