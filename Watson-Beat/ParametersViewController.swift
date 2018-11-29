//
//  ParametersViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/17/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa

class ParametersViewController: NSViewController {
    @IBOutlet weak var iniFilenameTextField: NSTextField!
    var mainViewController:MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        iniFilenameTextField.stringValue = WatsonMusic.shared().getIniParametersFilename() ?? ""
    }
    
    @IBAction func selectINIFileAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the INI Parameters File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["ini"]
        if iniFilenameTextField.stringValue.count < 1 {
            dialog.directoryURL = URL(fileURLWithPath: "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/Ini", isDirectory: true)
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            iniFilenameTextField.stringValue = dialog.url?.path ?? ""
        }
    }
    
    @IBAction func saveAction(_ sender: NSButton) {
        mainViewController.iniParametersFilename.stringValue = iniFilenameTextField.stringValue
        self.view.window?.close()
        WatsonMusic.shared().setIniParametersFilename(iniFilenameTextField.stringValue)
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        self.view.window?.close()
    }
}
