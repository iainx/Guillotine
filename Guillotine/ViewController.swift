//
//  ViewController.swift
//  Guillotine
//
//  Created by iain on 14/06/2015.
//  Copyright © 2015 False Victories. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: FVImageView!
    @IBOutlet weak var widthTextField: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!
    @IBOutlet weak var xOffsetTextField: NSTextField!
    @IBOutlet weak var yOffsetTextField: NSTextField!
    
    @IBOutlet weak var dropLabel: NSTextField!
    @IBOutlet weak var sliceButton: NSButton!
    
    @IBOutlet weak var widthStepper: NSStepper!
    @IBOutlet weak var heightStepper: NSStepper!
    @IBOutlet weak var xOffsetStepper: NSStepper!
    @IBOutlet weak var yOffsetStepper: NSStepper!
    @IBOutlet weak var summaryLabel: NSTextField!
    @IBOutlet weak var outputLabel: NSTextField!
    
    var offsetX = 0 {
        didSet {
            updateSummary()
            updateSliceGrid()
        }
    }
    
    var offsetY = 0 {
        didSet {
            updateSummary()
            updateSliceGrid()
        }
    }
    
    var sliceWidth = 64 {
        didSet {
            updateSummary ()
            updateSliceGrid()
        }
    }
    
    var sliceHeight = 64 {
        didSet {
            updateSummary ()
            updateSliceGrid()
        }
    }

    var minWidth = 1
    var minHeight = 1
    
    // Once an image is loaded this will be updated
    dynamic var maxWidth = 64
    dynamic var maxHeight = 64
    
    var imageFilename: String?
    
    override func awakeFromNib() {
        widthStepper.enabled = false
        heightStepper.enabled = false
        xOffsetStepper.enabled = false
        yOffsetStepper.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDropped:", name: kNewImageDroppedNotification, object: nil)
    }

    override func setNilValueForKey(key: String) {
        if key == "sliceWidth" || key == "sliceHeight" {
            return
        }

        super.setNilValueForKey(key)
    }
    
    func imageDropped (note: NSNotification) {
        guard let imageFile = note.object as? String,
              let image = NSImage (contentsOfFile: imageFile) else {
            return
        }

        imageView.image = image
        imageFilename = imageFile

        self.dropLabel.hidden = true
        self.widthTextField.enabled = true
        self.heightTextField.enabled = true
        self.xOffsetTextField.enabled = true
        self.yOffsetTextField.enabled = true
        self.widthStepper.enabled = true
        self.heightStepper.enabled = true
        self.xOffsetStepper.enabled = true
        self.yOffsetStepper.enabled = true
        
        self.sliceButton.enabled = true
        
        maxWidth = Int (image.size.width)
        maxHeight = Int (image.size.height)
        
        updateSummary()
        updateSliceGrid()
    }
    
    func generateAtlasPath (imagePath: String) -> String {
        let imageDir = imagePath.stringByDeletingLastPathComponent
        let basename = imagePath.lastPathComponent.stringByDeletingPathExtension
        let dirFilename = basename + ".atlas"
        
        let fullDirPath = String.pathWithComponents([imageDir, dirFilename])
        return fullDirPath
    }
    
    func updateSliceGrid () {
        imageView.sliceSize = CGSize (width: sliceWidth, height: sliceHeight)
        imageView.sliceOffset = CGPoint (x: offsetX, y: offsetY)
    }
    
    func updateSummary () {
        guard let image = imageView.image,
              let imagePath = imageFilename else {
            return
        }
        
        let rows = Int(image.size.height) / sliceHeight
        let columns = Int(image.size.width) / sliceWidth
        
        summaryLabel.stringValue = "Creating \(rows * columns) textures"
        outputLabel.stringValue = "Output file: \(generateAtlasPath(imagePath.stringByAbbreviatingWithTildeInPath))"
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sliceIt(sender: AnyObject) {
        guard let image = imageView.image,
              let imagePath = imageFilename else {
            return
        }
        
        // Lose focus on the text entries so that any changes in them are finalised
        widthTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        
        print ("\(sliceHeight)")
        
        let rows = Int (image.size.height) / sliceHeight
        let columns = Int (image.size.width) / sliceWidth

        let fileManager = NSFileManager.defaultManager()
        let fullDirPath = generateAtlasPath(imagePath)
        let basename = imagePath.lastPathComponent.stringByDeletingPathExtension
        
        do {
            try fileManager.createDirectoryAtPath(fullDirPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            let dialog = NSAlert (error: error)
            
            NSLog("Error creating directory path \(fullDirPath): \(error)")
            
            dialog.runModal()
        }
        
        for row in 0 ..< rows {
            for column in 0 ..< columns {
                let imageRect = NSRect (x: offsetX + (column * sliceWidth), y: offsetY + (row * sliceHeight), width: sliceWidth, height: sliceHeight)
                
                guard let cgImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue(),
                      let newCGImage = CGImageCreateWithImageInRect(cgImage, imageRect)else {
                    return
                }
                
                let newImageName = basename + "-\(row)-\(column).png"
                let newImagePath = String.pathWithComponents([fullDirPath, newImageName])
                
                let url = NSURL.fileURLWithPath(newImagePath)
                guard let imageDest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) else {
                    NSLog("Error creating image dest for \(newImagePath)")
                    return
                }
                
                CGImageDestinationAddImage(imageDest, newCGImage, nil)
                if !CGImageDestinationFinalize(imageDest) {
                    NSLog("Error writing image for \(newImagePath)")
                }
            }
        }
    }

}

