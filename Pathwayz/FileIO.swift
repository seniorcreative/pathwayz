//
//  FileIO.swift
//  Lesson07
//
//  Created by Steven Smith on 8/02/2016.
//  Copyright © 2016 General Assembly. All rights reserved.
//

import Foundation

class FileIO
{
    
    
    
    func write(file: String, withData: String) -> Bool
    {
        
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            //writing
            do {
                try withData.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                
                print("Saved contents to \(file)")
                
                return Bool(true)
            }
            catch {
                
                print("Error saving to file")
                
                return Bool(false)
            }
            
        }
        
        return Bool(false)
        
    }

    
    func read(file: String) -> String
    {
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            
            //reading
            do {
                let text = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                
                print("Text loaded from file")
                
                return text as String
                
                
            }
            catch {
                
                print("did not load anything")
                
                return String("")
                
            }
        }
        
        return String("")
        
    }

    
    
}