//
//  FVImageView.swift
//  Guillotine
//
//  Created by iain on 14/06/2015.
//  Copyright © 2015 False Victories. All rights reserved.
//

import Cocoa

class FVImageView: NSImageView {

    var droppedImageFilePath: String? = nil
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let acceptsDrag = super.performDragOperation(sender)
        
        if acceptsDrag {
            let pboard = sender.draggingPasteboard()
            guard let plist = pboard.stringForType(NSFilenamesPboardType) else {
                return false
            }
            
            guard let plistData = plist.dataUsingEncoding(NSUTF8StringEncoding) else {
                return false
            }
            
            do {
                let files = try NSPropertyListSerialization.propertyListWithData(plistData, options: NSPropertyListReadOptions.Immutable, format: nil)
                
                if files.count == 1 {
                    droppedImageFilePath = String (files[0])
                } else {
                    droppedImageFilePath = nil;
                    return false
                }
            } catch {
                return false
            }
        }
        
        return acceptsDrag
    }
}
