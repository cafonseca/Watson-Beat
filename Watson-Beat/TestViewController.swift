//
//  ViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/11/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa
import AudioKit
import CoreMIDI

class TestViewController: NSViewController {
    var sequencer:AKSequencer!
    var callbackInstrument:AKMIDICallbackInstrument!
    var midiOut:AKMIDI!
    @IBOutlet weak var popUpField: NSPopUpButton!
    @IBOutlet weak var msbTextField: NSTextField!
    @IBOutlet weak var lsbTextfield: NSTextField!
    @IBOutlet weak var programTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        midiOut = AudioKit.midi
        midiOut.openInput(midiOut.inputNames[0])
        print("Opening ouput \(midiOut.destinationNames[0])")
        midiOut.openOutput(midiOut.destinationNames[0])
        print("Output = \(midiOut.outputPort)")
        do {
            try AudioKit.start()
        } catch {
            print("Error \(error)")
        }
        
        popUpField.removeAllItems()
        popUpField.addItems(withTitles: ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16"])
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func openFileAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the MIDI file to open"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["mid"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            print("File: \(dialog.url?.path ?? "")")
            playMIDIFile((dialog.url?.path)!)
        }
    }
    
    func playMIDIFile(_ filename:String) {
        sequencer = AKSequencer(fromURL: URL(fileURLWithPath: filename))

        callbackInstrument = AKMIDICallbackInstrument()
        sequencer.tracks[0].setMIDIOutput(callbackInstrument.midiIn)
        callbackInstrument.callback = sequencerCallbackChannel_0
        sequencer.setGlobalMIDIOutput(callbackInstrument.midiIn)
        
        // Volume
        var event = AKMIDIEvent(controllerChange: 7, value: 50, channel: 0)
        midiOut.sendEvent(event)

        // Change instrument
        event = AKMIDIEvent(controllerChange: 0, value: 95, channel: 0)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 32, value: 64, channel: 0)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(programChange: 75, channel: 0)
        midiOut.sendEvent(event)

        sequencer.play()
    }
    
    func sequencerCallbackChannel_0(_ status: UInt8,
                           _ noteNumber: MIDINoteNumber,
                           _ velocity: MIDIVelocity) {
        
        print("time: \(sequencer.currentPosition.beats)")
        print("status: \(status), noteNumber: \(noteNumber), velocity: \(velocity)")
        
        if status == 144 {
            print("noteOn")
            let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            midiOut.sendEvent(event)
            
        } else if status == 128 {
            print("noteOff")
            //let event = AKMIDIEvent(noteOn: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            let event = AKMIDIEvent(noteOff: noteNumber, velocity: velocity, channel: MIDIChannel(0))
            midiOut.sendEvent(event)
        }
    }
    
    @IBAction func resetAction(_ sender: NSButton) {
        //sequencer.stop()
        var event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 0)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 0)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 0)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 0)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 1)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 1)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 1)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 1)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 2)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 2)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 2)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 2)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 3)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 3)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 3)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 3)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 4)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 4)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 4)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 4)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 5)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 5)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 5)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 5)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 6)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 6)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 6)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 6)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 7)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 7)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 7)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 7)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 8)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 8)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 8)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 8)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 9)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 9)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 9)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 9)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 10)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 10)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 10)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 10)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 11)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 11)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 11)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 11)
        midiOut.sendEvent(event)
        
        event = AKMIDIEvent(controllerChange: 120, value: 0, channel: 12)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 121, value: 0, channel: 12)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 123, value: 0, channel: 12)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 12)
        midiOut.sendEvent(event)
    }
    
    @IBAction func playNoteAction(_ sender: NSButton) {
        let channel = MIDIChannel((popUpField.selectedItem?.title)!)!-1
        let msb = MIDIByte(msbTextField.stringValue)
        let lsb = MIDIByte(lsbTextfield.stringValue)
        let program = MIDIByte(programTextField.stringValue)
        
        // Change instrument
        var event = AKMIDIEvent(controllerChange: 0, value: msb!, channel: channel)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 32, value: lsb!, channel: channel)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(programChange: program!, channel: channel)
        midiOut.sendEvent(event)
        
        let noteNumber = 60
        var velocity = 80
        event = AKMIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(velocity), channel: channel)
        midiOut.sendEvent(event)
        sleep(1)
        velocity = 0
        event = AKMIDIEvent(noteOff: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(velocity), channel: channel)
        midiOut.sendEvent(event)
    }
    
    @IBAction func programAction(_ sender: NSButton) {
        let channel = MIDIChannel((popUpField.selectedItem?.title)!)!-1
        let msb = MIDIByte(msbTextField.stringValue)
        let lsb = MIDIByte(lsbTextfield.stringValue)
        let program = MIDIByte(programTextField.stringValue)
        
        // Change instrument
        var event = AKMIDIEvent(controllerChange: 0, value: msb!, channel: channel)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(controllerChange: 32, value: lsb!, channel: channel)
        midiOut.sendEvent(event)
        event = AKMIDIEvent(programChange: program!, channel: channel)
        midiOut.sendEvent(event)
//        print("data1=\(event.data1)")
//        print("data2=\(event.data2)")
        print("internalData[0]=\(event.internalData[0])")
        print("internalData[1]=\(event.internalData[1])")
        print("internalData[2]=\(event.internalData[2])")
        event = AKMIDIEvent(controllerChange: 127, value: 0, channel: 0)
        midiOut.sendEvent(event)
    }
}

