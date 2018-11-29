//
//  WatsonBeatViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/23/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa
import AudioKit
import CoreMIDI

class WatsonBeatViewController: NSViewController, WatsonMusicDelegate {
    @IBOutlet weak var inspirationNewButton: NSButton!
    @IBOutlet weak var inspirationFilenameTextField: NSTextField!
    @IBOutlet weak var inspirationPlayButton: NSButton!
    @IBOutlet weak var inspirationStopButton: NSButton!
    @IBOutlet weak var parametersFilenameTextField: NSTextField!
    @IBOutlet weak var outputDirectoryTextField: NSTextField!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var loopButton: NSButton!
    @IBOutlet weak var scrollTextView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        WatsonMusic.shared().watsonMusicDelegate = self
        
        var displayValue = FileManager.default.displayName(atPath: WatsonMusic.shared().getInspirationMidiFilename()!)
        updateInspirationFilenameTextField(displayValue)

        displayValue = FileManager.default.displayName(atPath: WatsonMusic.shared().getIniParametersFilename()!)
        parametersFilenameTextField.stringValue = displayValue
        
        displayValue = FileManager.default.displayName(atPath: WatsonMusic.shared().getOutputDirectory()!)
        outputDirectoryTextField.stringValue = displayValue
    }
    
    func updateInspirationFilenameTextField(_ text:String) {
        inspirationFilenameTextField.stringValue = text
        if inspirationFilenameTextField.stringValue.count > 0 {
            inspirationPlayButton.isEnabled = true
        } else {
            inspirationPlayButton.isEnabled = false
        }
    }
    
    @IBAction func inspirationFilenameSelectButtonAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the inspiration MIDI File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.directoryURL = URL(fileURLWithPath: WatsonMusic.shared().getInspirationMidiFilename()!, isDirectory: true)
        dialog.allowedFileTypes = ["mid"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let displayValue = FileManager.default.displayName(atPath: dialog.url?.path ?? "")
            updateInspirationFilenameTextField(displayValue)
            WatsonMusic.shared().setInspirationMidiFilename(dialog.url?.path ?? "")
        }
    }
    
    func playInspirationMidiFile() {
        inspirationNewButton.isEnabled = false
        inspirationPlayButton.isEnabled = false
        inspirationStopButton.isEnabled = true
        WatsonMusic.shared().play(midiFile: WatsonMusic.shared().getInspirationMidiFilename()!)
    }
    
    func stopInspirationPlay() {
        inspirationNewButton.isEnabled = true
        inspirationPlayButton.isEnabled = true
        inspirationStopButton.isEnabled = false
        WatsonMusic.shared().StopAndReset()
    }
    
    @IBAction func inspirationPlayButtonAction(_ sender: NSButton) {
        playInspirationMidiFile()
    }
    
    
    @IBAction func inspirationStopButtonAction(_ sender: NSButton) {
        stopInspirationPlay()
    }
    
    @IBAction func parametersFilenameSelectButtonAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the INI Parameters File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["ini"]
        dialog.directoryURL = URL(fileURLWithPath: WatsonMusic.shared().getIniParametersFilename()!, isDirectory: true)

        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            WatsonMusic.shared().setIniParametersFilename(dialog.url?.path ?? "")
            let displayValue = FileManager.default.displayName(atPath: dialog.url?.path ?? "")
            parametersFilenameTextField.stringValue = displayValue
        }
    }
    
    @IBAction func outputDirectorySelectButtonAction(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select the MIDI Output Directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.canCreateDirectories = true
        dialog.directoryURL = URL(fileURLWithPath: WatsonMusic.shared().getOutputDirectory()!, isDirectory: true)
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            WatsonMusic.shared().setOutpuDirectory(dialog.url?.path ?? "")
            let displayValue = FileManager.default.displayName(atPath: dialog.url?.path ?? "")
            outputDirectoryTextField.stringValue = displayValue
        }
    }
    
    
    @IBAction func generateWatsonMusicButtonAction(_ sender: NSButton) {
        let path = WatsonMusic.shared().getOutputDirectory()
        let fileNames = try! FileManager.default.contentsOfDirectory(atPath: path!)
        
        if fileNames.count > 0 {
            let a: NSAlert = NSAlert()
            a.messageText = "Delete files in directory?"
            a.informativeText = "Output directory not empty. To generate, the output directory needs to be empty. Delete files from the output directory?"
            a.addButton(withTitle: "Delete")
            a.addButton(withTitle: "Cancel")
            a.alertStyle = NSAlert.Style.warning
            
            a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) -> Void in
                if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                    print("Delete files in the directory: \(path!)")
                    for filename in fileNames {
                        do {
                            try FileManager.default.removeItem(atPath: path! + "/" + filename)
                        } catch let error as NSError {
                            print("Ooops! Something went wrong: \(error)")
                        }
                    }
                    self.generate()
                }
            })
        } else {
            generate()
        }
    }
    
    private func generate() {
        inspirationNewButton.isEnabled = false
        inspirationPlayButton.isEnabled = false
        playButton.isEnabled = false
        stopButton.isEnabled = false

        let task = Process()
        task.launchPath = "/Users/fonseca/.pyenv/shims/python"
        task.currentDirectoryPath = "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/"
        //task.arguments = ["wbDev.py", "-i", "Ini/ReggaePop.ini", "-m", "Midi/ode_to_joy.mid", "-o", "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/output2/"]
        task.arguments = (["wbDev.py", "-i", WatsonMusic.shared().getIniParametersFilename(), "-m", WatsonMusic.shared().getInspirationMidiFilename() , "-o", WatsonMusic.shared().getOutputDirectory()! + "/"] as! [String])
        
        //self.outputScrollView.documentView?.insertText("Watson is working.... please wait\n\n")
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var obs1 : NSObjectProtocol!
        obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                      object: outHandle, queue: OperationQueue.main) {  notification -> Void in
                                                        let data = outHandle.availableData
                                                        if data.count > 0 {
                                                            if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                                                print("\(str)")
                                                                DispatchQueue.main.async(execute: {
                                                                    self.scrollTextView.documentView?.insertText(str)
                                                                })
                                                            }
                                                            outHandle.waitForDataInBackgroundAndNotify()
                                                        } else {
                                                            print("EOF on stdout from process")
                                                            DispatchQueue.main.async(execute: {
                                                                self.scrollTextView.documentView?.insertText("\nEOF on stdout from process\n")
                                                            })

                                                            NotificationCenter.default.removeObserver(obs1)
                                                        }
        }
        
        var obs2 : NSObjectProtocol!
        obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                      object: task, queue: nil) { notification -> Void in
                                                        let data = outHandle.availableData
                                                        if data.count > 0 {
                                                            if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                                                DispatchQueue.main.async(execute: {
                                                                    self.scrollTextView.documentView?.insertText(str)
                                                                    self.scrollTextView.documentView?.insertText("\n*****Finished******\n")
                                                                })
                                                            }
                                                        }
                                                        print("Finished")
                                                        DispatchQueue.main.async(execute: {
                                                            self.scrollTextView.documentView?.insertText("\n*****Finished******\n")
                                                            self.inspirationNewButton.isEnabled = true
                                                            self.inspirationPlayButton.isEnabled = true
                                                            self.playButton.isEnabled = true
                                                            self.stopButton.isEnabled = false

                                                        })

                                                        NotificationCenter.default.removeObserver(obs2)
        }
        task.launch()
    }
    
    func play() {
        inspirationNewButton.isEnabled = false
        inspirationPlayButton.isEnabled = false
        playButton.isEnabled = false
        stopButton.isEnabled = true
        if loopButton.state == .on {
            WatsonMusic.shared().play(andLoop: true)
        } else {
            WatsonMusic.shared().play()
        }
    }
    
    func stop() {
        inspirationNewButton.isEnabled = true
        inspirationPlayButton.isEnabled = true
        playButton.isEnabled = true
        stopButton.isEnabled = false
        WatsonMusic.shared().StopAndReset()
    }
    
    @IBAction func playButtonAction(_ sender: NSButton) {
        play()
    }
    
    @IBAction func stopButtonAction(_ sender: NSButton) {
        stop()
    }
    
    @IBAction func resetButtonAction(_ sender: NSButton) {
        WatsonMusic.shared().StopAndReset()
    }
    
    @IBAction func clearButtonAction(_ sender: NSButton) {
        //textView.selectAll(sender)
        textView.string = ""
    }
    
    func midiInstrumentCallbackMessage(status: UInt8, noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: UInt8, message: String) {
        DispatchQueue.main.async(execute: {
            self.scrollTextView.documentView?.insertText(message + "\n")
        })
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordSegue" {
            (segue.destinationController as? RecordViewController)?.watsonBeatViewController = self
        }
    }

}
