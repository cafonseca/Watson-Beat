//
//  GenerateViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/17/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa

class GenerateViewController: NSViewController {
    var mainViewController:MainViewController!
    var outputPipe:Pipe!
    @IBOutlet weak var outputDirectoryTextField: NSTextField!
    @IBOutlet weak var outputScrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        outputDirectoryTextField.stringValue = WatsonMusic.shared().getOutputDirectory() ?? ""
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
        if outputDirectoryTextField.stringValue.count < 1 {
            dialog.directoryURL = URL(fileURLWithPath: "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src", isDirectory: true)
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            outputDirectoryTextField.stringValue = dialog.url?.path ?? ""
            WatsonMusic.shared().setOutpuDirectory(outputDirectoryTextField.stringValue)
        }
    }
    
    @IBAction func generateAction(_ sender: NSButton) {
        let path = outputDirectoryTextField.stringValue
        let fileNames = try! FileManager.default.contentsOfDirectory(atPath: path)
        
        if fileNames.count > 0 {
            let a: NSAlert = NSAlert()
            a.messageText = "Delete files in directory?"
            a.informativeText = "Output directory not empty. To generate, the output directory needs to be empty. Delete files from the output directory?"
            a.addButton(withTitle: "Delete")
            a.addButton(withTitle: "Cancel")
            a.alertStyle = NSAlert.Style.warning
            
            a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) -> Void in
                if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                    print("Delete files in the directory: \(self.outputDirectoryTextField.stringValue)")
                    for filename in fileNames {
                        do {
                            try FileManager.default.removeItem(atPath: path + "/" + filename)
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
        
    @IBAction func closeAction(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    private func generate() {
        // python wbDev.py -i Ini/ReggaePop.ini -m Midi/ode_to_joy.mid -o /Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/output2/
        let task = Process()
        //        task.launchPath = "/bin/sh"
        //        task.arguments = ["-c", "echo 1 ; sleep 1 ; echo 2 ; sleep 1 ; echo 3 ; sleep 1 ; echo 4"]
        
        task.launchPath = "/Users/fonseca/.pyenv/shims/python"
        task.currentDirectoryPath = "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/"
        //task.arguments = ["wbDev.py", "-i", "Ini/ReggaePop.ini", "-m", "Midi/ode_to_joy.mid", "-o", "/Users/fonseca/Development/git/github.com/cognitive-catalyst/watson-beat/src/output2/"]
        task.arguments = (["wbDev.py", "-i", WatsonMusic.shared().getIniParametersFilename(), "-m", WatsonMusic.shared().getInspirationMidiFilename() , "-o", WatsonMusic.shared().getOutputDirectory()! + "/"] as! [String])
        
        self.outputScrollView.documentView?.insertText("Watson is working.... please wait\n\n")
        
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
                                                                print("got output: \(str)")
                                                            }
                                                            outHandle.waitForDataInBackgroundAndNotify()
                                                        } else {
                                                            print("EOF on stdout from process")
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
                                                                    self.outputScrollView.documentView?.insertText(str)
                                                                    self.outputScrollView.documentView?.insertText("\n*****Finished******\n")
                                                                })
                                                            }
                                                        }
                                                        print("Finished")
                                                        NotificationCenter.default.removeObserver(obs2)
        }
        task.launch()
    }
}

