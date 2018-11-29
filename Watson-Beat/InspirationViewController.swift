//
//  InspirationViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/17/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa

class InspirationViewController: NSViewController {
    var mainViewController:MainViewController!
    @IBOutlet weak var filenameTextField: NSTextField!
    
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The following only works w you are editing the field, doesn't generate the noticiation when you set the stringValue
        NotificationCenter.default.addObserver(forName: NSTextField.textDidChangeNotification, object: filenameTextField, queue: OperationQueue.main) {  notification -> Void in
            print("Notification \(notification)")
            if self.filenameTextField.stringValue.count > 0 {
                self.playButton.isEnabled = true
            } else {
                self.playButton.isEnabled = false
            }
        }
        updateFilenameTextField(WatsonMusic.shared().getInspirationMidiFilename() ?? "")
    }
    
    func updateFilenameTextField(_ text:String) {
        filenameTextField.stringValue = text
        if filenameTextField.stringValue.count > 0 {
            playButton.isEnabled = true
        } else {
            playButton.isEnabled = false
        }
    }
    
    @IBAction func selectMidiFileAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the MIDI File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        if filenameTextField.stringValue.count < 1 {
            dialog.directoryURL = URL(fileURLWithPath: "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/Midi", isDirectory: true)
        }
        dialog.allowedFileTypes = ["mid"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            updateFilenameTextField(dialog.url?.path ?? "")
        }
    }
    
    @IBAction func playAction(_ sender: NSButton) {
        WatsonMusic.shared().play(midiFile: filenameTextField.stringValue)
    }
    
    @IBAction func stopAction(_ sender: NSButton) {
        WatsonMusic.shared().StopAndReset()
    }
    
    @IBAction func saveAction(_ sender: NSButton) {
        mainViewController.inspirationMidiFilename.stringValue = filenameTextField.stringValue
        self.view.window?.close()
        WatsonMusic.shared().setInspirationMidiFilename(filenameTextField.stringValue)
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        self.view.window?.close()
    }
    

}
