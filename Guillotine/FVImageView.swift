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

        guard let slices = sliceSize else {
            return
        }
        
        let size = frame.size
        let columns = (size.width / slices.width)
        let rows = (size.height / slices.height)
        
        NSColor.lightGrayColor().setStroke()
        
        for row in 1 ..< Int(rows) {
            let y = size.height - (CGFloat(row) * slices.height)
            NSBezierPath.strokeLineFromPoint(NSPoint(x: 0.0, y: y), toPoint: NSPoint (x: size.width, y: y))
        }
        
        for column in 1 ..< Int(columns) {
            let x = size.width - (CGFloat(column) * slices.width)
            NSBezierPath.strokeLineFromPoint(NSPoint(x: x, y: 0.0), toPoint: NSPoint (x: x, y: size.height))
        }
    }
}
