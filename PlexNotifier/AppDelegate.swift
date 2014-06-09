//
//  AppDelegate.swift
//  PlexNotifier
//
//  Created by Joseph Pintozzi on 6/8/14.
//  Copyright (c) 2014 pyro2927. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, SRWebSocketDelegate, NSUserNotificationCenterDelegate {
                            
    @IBOutlet var window: NSWindow


    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        fetchMyPlexToken()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

    func fetchMyPlexToken() {
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername("PLEXUSERNAME", password: "PLEXPASSWORD")
        manager.requestSerializer.setValue("PlexNotifier for OS X", forHTTPHeaderField: "X-Plex-Client-Identifier")
        
        //post to our sign in
        manager.POST("https://my.plexapp.com/users/sign_in.json", parameters: nil, success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            if let response = responseObject as? NSDictionary {
                var user: NSDictionary = response["user"] as NSDictionary
                var token: String = user["authentication_token"] as String
                NSLog(token)
                self.connectToWebSocket(token)
                let serverClient = PlexServerRequestManager.init(baseURL: NSURL.URLWithString("http://server.example.com:32400"))
                serverClient.getCurrentSessions();
            }
            
        }, failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
            NSLog("Failed login")
        })
    }
    
    func connectToWebSocket(authenticationToken: String!) {
        let url:NSURL = NSURL(string:"http://server.example.com:32400/:/websockets/notifications?X-Plex-Token=" + authenticationToken)
        let request:NSURLRequest = NSURLRequest(URL:url)
        let websocket = SRWebSocket(URLRequest: request)
        websocket.delegate = self
        websocket.open()
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        NSLog("Websocket message received")
        if let messageString = message as? String {
            var messageDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(messageString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) , options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            for (key, value) in messageDictionary {
                println("\(key): \(value)")
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        NSLog("Websocket failed to open")
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter!, shouldPresentNotification notification: NSUserNotification!) { true }
}