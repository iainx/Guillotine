//
//  FVDragWindow.swift
//  Guillotine
//
//  Created by iain on 20/06/2015.
//  Copyright © 2015 False Victories. All rights reserved.
//

import Cocoa

class FVDragWindow: NSWindow {

    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, `defer`: flag)
        
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.registerForDraggedTypes([NSFilenamesPboardType])
        NSLog ("Createed wendow");
    }
    
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard()
        guard let pboardTypes = pboard.types else {
            return NSDragOperation.None
        }
        
        if pboardTypes.contains(NSFilenamesPboardType) {
            return NSDragOperation.Copy
        }
        
        return NSDragOperation.None
    }
    
    func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }

    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        let availableType = pboard.availableTypeFromArray([NSFilenamesPboardType])

        if (availableType != NSFilenamesPboardType) {
            return false
        }
        
        guard let plist = pboard.propertyListForType(NSFilenamesPboardType) as? NSArray else {
            return false
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kNewImageDroppedNotification, object: plist[0])
        return true
    }
}
