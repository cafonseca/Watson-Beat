//
//  PlayMusicViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/15/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa

class PlayMusicViewController: NSViewController {
    var mainViewController:MainViewController!
    @IBOutlet weak var directoryTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        directoryTextField.stringValue = WatsonMusic.shared().getOutputDirectory() ?? ""
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func changeDirectoryAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the MIDI Output Directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.canCreateDirectories = true
        if directoryTextField.stringValue.count < 1 {
            dialog.directoryURL = URL(fileURLWithPath: "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/Midi", isDirectory: true)
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            directoryTextField.stringValue = dialog.url?.path ?? ""
        }
    }
    
    @IBAction func playAction(_ sender: NSButton) {
        if directoryTextField.stringValue.count > 0 {
            print("Directory: \(directoryTextField.stringValue)")
            WatsonMusic.shared().play(filesInDirectory: directoryTextField.stringValue, andLoop: false)
        }
    }
}
