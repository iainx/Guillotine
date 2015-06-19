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
    
    @IBOutlet weak var dropLabel: NSTextField!
    @IBOutlet weak var sliceButton: NSButton!
    
    @IBOutlet weak var widthStepper: NSStepper!
    @IBOutlet weak var heightStepper: NSStepper!
    @IBOutlet weak var summaryLabel: NSTextField!
    @IBOutlet weak var outputLabel: NSTextField!
    
    private var imageContext = 0
    
    var sliceWidth = 64 {
        didSet {
            NSLog("Width set")
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
    
    deinit {
        imageView.removeObserver(self, forKeyPath: "image", context: &imageContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        widthStepper.enabled = false
        heightStepper.enabled = false
        
        // Do any additional setup after loading the view.
        imageView.addObserver(self, forKeyPath: "image", options: .New, context: &imageContext)
    }

    override func setNilValueForKey(key: String) {
        if key == "sliceWidth" || key == "sliceHeight" {
            return
        }

        super.setNilValueForKey(key)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != &imageContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        // Hide the drop label when we have an image to slice
        if keyPath == "image" {
            if let image = imageView.image {
                self.dropLabel.hidden = true
                self.widthTextField.enabled = true
                self.heightTextField.enabled = true
                self.widthStepper.enabled = true
                self.heightStepper.enabled = true
                self.sliceButton.enabled = true
                
                maxWidth = Int (image.size.width)
                maxHeight = Int (image.size.height)
                
                updateSummary()
                updateSliceGrid()
            }
        }
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
    }
    
    func updateSummary () {
        guard let image = imageView.image,
              let imagePath = imageView.droppedImageFilePath else {
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
              let imagePath = imageView.droppedImageFilePath else {
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
                let imageRect = NSRect (x: column * sliceWidth, y: row * sliceHeight, width: sliceWidth, height: sliceHeight)
                
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

