//
//  MyPlexRequestManager.swift
//  PlexNotifier
//
//  Created by Joseph Pintozzi on 6/12/14.
//  Copyright (c) 2014 pyro2927. All rights reserved.
//

import Cocoa

struct PlexServer {
    var name: String?
    var ipAddress: String?
    var token: String?
    var owned: Boolean?
}

class MyPlexRequestManager: PlexServerRequestManager {
    
    init() {
        super.init(baseURL: NSURL.URLWithString("https://plex.tv/"))
    }
    
    func getServers(callback: ((Array<PlexServer>?, NSError?) -> Void)?) {
        self.GET("servers.xml", parameters: nil, success: {(sessionTask: NSURLSessionDataTask!, responseObject: AnyObject!) in
            var xmlDocument: NSXMLDocument = responseObject as NSXMLDocument
            let rootElement: NSXMLElement = xmlDocument.rootElement()
            var servers = Array<PlexServer>()
            let mediaContainers: Array<NSXMLElement> = rootElement.children as Array<NSXMLElement>
            let mediaElements: Array<NSXMLElement> = mediaContainers[0].children as Array<NSXMLElement>
            for media: NSXMLElement in mediaElements {
                if media.name == "Server" {
                    servers.append(PlexServer(name: media.attributeForName("name").stringValue, ipAddress: media.attributeForName("lovalAddresses").stringValue, token: <#String?#>, owned: true))
                }
            }
        }, failure: {(sessionTask: NSURLSessionDataTask!, error: NSError!) in
            if let respond = callback {
                respond(nil, error)
            }
        })
    }

}
