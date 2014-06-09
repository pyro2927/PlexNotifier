//
//  PlexServerRequestManager.swift
//  PlexNotifier
//
//  Created by Joseph Pintozzi on 6/8/14.
//  Copyright (c) 2014 pyro2927. All rights reserved.
//

import Cocoa

class PlexServerRequestManager: AFHTTPSessionManager {
    
    init(baseURL url: NSURL!) {
        super.init(baseURL: url, sessionConfiguration: nil)
        responseSerializer = AFXMLDocumentResponseSerializer();
    }
    
    func setPlexToken(plexToken: String!) {
        self.requestSerializer.setValue(plexToken, forHTTPHeaderField: "X-Plex-Token")
    }
    
    func getCurrentSessions() {
        self.GET("/status/sessions", parameters: nil, success: {(sessionTask: NSURLSessionDataTask!, responseObject: AnyObject!) in
            var xmlDocument: NSXMLDocument = responseObject as NSXMLDocument
            let rootElement: NSXMLElement = xmlDocument.rootElement()
            let videos: Array<NSXMLElement> = rootElement.children as Array<NSXMLElement>
            for video: NSXMLElement in videos {
                var videotitle = video.attributeForName("title").stringValue
                if let grandparentTitle = video.attributeForName("grandparentTitle").stringValue {
                    videotitle = "\(grandparentTitle): \(videotitle)"
                }
                var username = "Unknown"
                var player = ""
                for child: NSXMLElement in video.children as Array<NSXMLElement> {
                    let childname: String = child.name
                    switch childname {
                    case "User":
                        println("Found user!")
                        username = child.attributeForName("title").stringValue
                    case "Player":
                        player = child.attributeForName("product").stringValue
                    default:
                        println("Not using this node")
                    }
                }
                let newNotification = NSUserNotification();
                newNotification.title = "\(username) is watching \(videotitle)"
                newNotification.subtitle = player
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(newNotification)
            }
        }, failure: {(sessionTask: NSURLSessionDataTask!, error: NSError!) in
            
        })
    }
}