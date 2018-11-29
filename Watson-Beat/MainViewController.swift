//
//  MainViewController.swift
//  Watson-Beat
//
//  Created by fonseca on 11/15/18.
//  Copyright © 2018 IBM Research. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var inspirationMidiFilename: NSTextField!
    @IBOutlet weak var iniParametersFilename: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func resetAction(_ sender: NSButton) {
        WatsonMusic.shared().StopAndReset()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "inspirationSegue" {
            (segue.destinationController as? InspirationViewController)?.mainViewController = self
        } else if segue.identifier == "parametersSegue" {
            (segue.destinationController as? ParametersViewController)?.mainViewController = self
        } else if segue.identifier == "generateSegue" {
            (segue.destinationController as? GenerateViewController)?.mainViewController = self
        } else if segue.identifier == "playMusicSegue" {
            (segue.destinationController as? PlayMusicViewController)?.mainViewController = self
        }
    }
}
