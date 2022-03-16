//
//  ProcessManager.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/13/22.
//

import Foundation
import AppKit
import AXSwift


class ProcessManager {
    
    private var app: Application?
    private var window: UIElement?
    
    static let instance = ProcessManager()
    
    init() {
        findXIV()
    }
    
    func findXIV() {
        // Reset app to nil in case it was closed
        app = nil
        
        // Find apps that have a UI
        let apps = NSWorkspace.shared.runningApplications.filter { app in
            app.activationPolicy == .regular
        }
        
        // Find all wine apps
        let wineApps = apps.filter { app in
            app.localizedName?.contains("wine") == true
        }
        
        // If there's only one, then assume it's the game
        if wineApps.count == 1, let xivApp = wineApps.first {
            app = Application(xivApp)
            do {
                if let currentApp = app {
                    if let foundWindow = try currentApp.windows()?.first(where: {try $0.attribute(.title) == "FINAL FANTASY XIV"}) {
                        window = foundWindow
                    }
                }
            } catch {
                return
            }
        } else {
            // If there's more than one, then we can't reliably find the game process
            return
        }
    }
    
    func getXIVProcessId() -> pid_t? {
        do {
            return try app?.pid()
        } catch {
            return nil
        }
    }
    
    func switchToXIV() {
        do {
            try app?.setAttribute(.frontmost, value: kCFBooleanTrue!)
            try window?.setAttribute(.main, value: kCFBooleanTrue!)
        } catch {
            return
        }
    }
}
