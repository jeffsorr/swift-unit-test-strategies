//
//  MyCode.swift
//  UnitTestStrategies
//
//  Created by Jeff Sorrentino on 2/20/19.
//  Copyright © 2019 SeaDogDev. All rights reserved.
//

import Foundation

/// Simple function to add numbers
func mySum(_ a: Int, _ b: Int) -> Int {
    return a + b
}

/// Simple function with a completion block
func myReverseStringAsync(_ string: String, completion: @escaping (_ result: String) -> Void) {
    
    if string == "" {
        completion("")
        return
    }
    
    DispatchQueue.global().async {
        completion(String(string.reversed()))
    }
}

/// Function with success and failure completion blocks
func getResults(_ providerName: AnyObject, success: @escaping (_ names:[String]?)->Void,
                failure: @escaping (_ error: Error)->Void) {
    if let _ = providerName as? String {
        success(["result1", "result2"])
        return
    }
    failure(NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "providerName must be a string"]))
}

/// Function with status and results completion blocks
func getResultsWithStatus(_ providerName: AnyObject, status: @escaping (_ canQuery: Bool)->Void,
                          results: @escaping (_ names:[String]?)->Void) {
    if let _ = providerName as? String {
        status(true)
    }
    results(["result1", "result2"])
}


extension Notification.Name {
    static let fileLoaded = Notification.Name("fileLoaded")
    static let foo = Notification.Name("foo")
}

class FileLoader {
    
    var preloadedFiles: [String] = []
    
    /// Load an array of files asynchronously
    func preloadFiles(_ fileNames: [String], on: DispatchQueue) {
        on.async {
            fileNames.forEach { fileName in
                Thread.sleep(forTimeInterval: 1) //simulate a delay for the preload
                self.preloadedFiles.append(fileName)
            }
        }
    }
    
    func loadFile(_ fileName: String) {
        
        DispatchQueue.global().async {
            NotificationCenter.default.post(name: .fileLoaded, object: self, userInfo: ["successCode" : 1])
        }
        
    }
    
}

protocol MessageSenderDelegate {
    func messageReceived(message: String)
}

class MessageSender {
    var delegate: MessageSenderDelegate?
    
    func sendMessage(_ message: String) {
        delegate?.messageReceived(message: "\(message) was sent!")
    }
}
