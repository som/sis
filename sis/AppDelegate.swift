//
//  AppDelegate.swift
//  sis
//
//  Created by som on 12/02/2017.
//  Copyright © 2017 som. All rights reserved.
//

import Cocoa
import AppKit.NSEvent
import Carbon

var aKeyInputSources:[TISInputSource]?

let cmdLeft:UInt = 1048840
let cmdRight:UInt = 1048848


var flagCmd:UInt = 0
var flagKey:Int = 0
func cbFlags(event:NSEvent){
    if (event.modifierFlags.contains(NSEventModifierFlags.command)){
        if (flagCmd == 0){
            flagCmd = event.modifierFlags.rawValue;
        }else{
            flagCmd = 0;
        }
    }else{
        if (flagKey == 0){
            if (flagCmd == cmdLeft){
                TISSelectInputSource( aKeyInputSources![0] )
            }else if (flagCmd == cmdRight){
                TISSelectInputSource( aKeyInputSources![1] )
            }
        }
        flagCmd = 0;
    }
    
}

func cbDown(event:NSEvent){
    if (!event.isARepeat){
        flagKey += 1
    }
}

func cbUp(event:NSEvent){
    flagKey -= 1
}

func getProperty<T>(_ source: TISInputSource, _ key: CFString) -> T? {
    let cfType = TISGetInputSourceProperty(source, key)
    if (cfType != nil) {
        return Unmanaged<AnyObject>.fromOpaque(cfType!).takeUnretainedValue() as? T
    } else {
        return nil
    }
}

func filterSources(i:TISInputSource) -> Bool{
    let selectable: Bool = getProperty(i, kTISPropertyInputSourceIsSelectCapable)!
    if (!selectable){ return false }
    
    let category: String = getProperty(i, kTISPropertyInputSourceCategory)!
    return category == (kTISCategoryKeyboardInputSource as String)
}


var mntDown:Any?
var mntUp:Any?
var mntFlg:Any?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let sources = (TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray) as? [TISInputSource]
        aKeyInputSources = sources?.filter( filterSources )
        print( "aInputSources \(aKeyInputSources!.count)" )
        
        var options: [String: Bool] = [:]
        options[kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String] = true
        NSLog("Init \(AXIsProcessTrustedWithOptions(options as CFDictionary))")
        // Insert code here to initialize your application
        
        mntDown = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown, handler: cbDown)
        mntUp = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyUp, handler: cbUp)
        mntFlg = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: cbFlags)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NSEvent.removeMonitor( mntFlg! )
        NSEvent.removeMonitor( mntDown! )
        NSEvent.removeMonitor( mntUp! )
    }


}

