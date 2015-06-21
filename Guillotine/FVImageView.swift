//
//  FVImageView.swift
//  Guillotine
//
//  Created by iain on 14/06/2015.
//  Copyright © 2015 False Victories. All rights reserved.
//

import Cocoa

class FVImageView: NSImageView {
    var sliceSize: CGSize? {
        didSet {
            if sliceSize!.width == 0 || sliceSize!.height == 0 {
                return
            }
            needsDisplay = true
        }
    }
    
    var sliceOffset: CGPoint? {
        didSet {
            needsDisplay = true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        guard let slices = sliceSize else {
            return
        }
        
        var xOffset: CGFloat = 0.0;
        var yOffset: CGFloat = 0.0;
        
        if let offset = sliceOffset {
            xOffset = offset.x
            yOffset = offset.y
        }

        let size = frame.size
        let columns = (size.width / slices.width)
        let rows = (size.height / slices.height)
        
        NSColor.lightGrayColor().setStroke()
        
        for var row = 0; row <= Int(rows); row++ {
            let y = size.height - (yOffset + CGFloat(row) * slices.height)
            NSBezierPath.strokeLineFromPoint(NSPoint(x: xOffset, y: y), toPoint: NSPoint (x: size.width - xOffset, y: y))
        }
        
        for var column = 0; column <= Int(columns); column++ {
            let x = xOffset + (CGFloat(column) * slices.width)
            NSBezierPath.strokeLineFromPoint(NSPoint(x: x, y: yOffset), toPoint: NSPoint (x: x, y: size.height - yOffset))
        }
    }
}
