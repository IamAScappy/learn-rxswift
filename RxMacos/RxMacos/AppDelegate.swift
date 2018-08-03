//
//  AppDelegate.swift
//  RxMacos
//
//  Created by JK on 03/08/2018.
//  Copyright © 2018 codesquad. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      print("Application Did Finish Launching")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
      print("Application Will Terminate")
    }
}

