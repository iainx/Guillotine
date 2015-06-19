//
//  FVImageView.swift
//  Guillotine
//
//  Created by iain on 14/06/2015.
//  Copyright © 2015 False Victories. All rights reserved.
//

import Cocoa

/// An NSImageView subclass which stores the filename of the image dropped onto it
class FVImageView: NSImageView {

    var droppedImageFilePath: String? = nil
    var sliceSize: CGSize? {
        didSet {
            if sliceSize!.width == 0 || sliceSize!.height == 0 {
                return
            }
            needsDisplay = true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        guard let slices = sliceSize else {
            return
        }
        
        let size = frame.size
        let columns = (size.width / slices.width)
        let rows = (size.height / slices.height)
        
        if let context = NSGraphicsContext.currentContext()?.CGContext {
            
            CGContextSetStrokeColorWithColor(context, NSColor.lightGrayColor().CGColor)
            
            for row in 0 ..< Int(rows) {
                let y = size.height - (CGFloat(row) * slices.height)
                CGContextMoveToPoint(context, 0.0, y)
                CGContextAddLineToPoint(context, size.width, y)
                CGContextStrokePath(context)
            }
            
            for column in 0 ..< Int(columns) {
                let x = CGFloat(column) * slices.width
                CGContextMoveToPoint(context, x, 0.0)
                CGContextAddLineToPoint(context, x, size.height)
                CGContextStrokePath(context)
            }
        }
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
