//
//  ProcessManager.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/13/22.
//

import Foundation
import AppKit


class ProcessManager {
    
    private var xivApp: NSRunningApplication?
    
    static let instance = ProcessManager()
    
    init() {
        setXIVProcessId()
    }
    
    func setXIVProcessId() {
        // Find apps that have a UI
        let apps = NSWorkspace.shared.runningApplications.filter { app in
            app.activationPolicy == .regular
        }
        
        // Find all wine apps
        let wineApps = apps.filter { app in
            app.localizedName?.contains("wine") == true
        }
        
        // If there's only one, then assume it's the game
        if wineApps.count == 1 {
            xivApp =  wineApps.first
        } else {
            // If there's more than one, then we can't reliably find the game process
            xivApp = nil
        }
    }
    
    func getXIVProcessId() -> pid_t? {
        return xivApp?.processIdentifier
    }
}
