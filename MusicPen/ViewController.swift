//
//  ViewController.swift
//  MusicPen
//
//  Created by 김민호 on 2021/06/17.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver{
    
    @IBOutlet var pencilFingerButton: UIBarButtonItem!
    @IBOutlet var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHight: CGFloat = 500
    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window){
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
        
    }
    
    @IBAction func saveDrawingToCameraRoll(_ sender: Any) {
    }
}
