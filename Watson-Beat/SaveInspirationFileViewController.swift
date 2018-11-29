//
//  SaveInspirationFileViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/24/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa
import AudioKit

class SaveInspirationFileViewController: NSViewController {
    @IBOutlet weak var filenameTextField: NSTextField!
    var recordViewController:RecordViewController!
    var watsonBeatViewController:WatsonBeatViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
//        let seq = AKSequencer()
//        let t = seq.newTrack("something")
//        recordViewController.recordingTrack.copyAndMergeTo(musicTrack: t!)
//        seq.setTempo(60)
//        seq.setLength(AKDuration(beats: Double(16)))
        recordViewController.sequencer.deleteTrack(trackIndex: 0)
        print("Number tracks = \(recordViewController.sequencer.tracks.count)")
        let data = recordViewController.sequencer.genData()
//        print("Number tracks = \(seq.tracks.count)")
//        let data = seq.genData()
        var filename = "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/Midi/" + filenameTextField.stringValue
        if !filenameTextField.stringValue.contains(".mid") {
            filename = filename + ".mid"
        }
        FileManager.default.createFile(atPath: filename, contents: data, attributes: [:])
        let displayValue = FileManager.default.displayName(atPath: filename)
        WatsonMusic.shared().setInspirationMidiFilename(filename)
        watsonBeatViewController.updateInspirationFilenameTextField(displayValue)
        self.view.window?.close()
    }
}
