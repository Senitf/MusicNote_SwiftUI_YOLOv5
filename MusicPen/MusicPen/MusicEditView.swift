//
//  MusicEditView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/22.
//

import SwiftUI
import PencilKit
import UIKit.UIGestureRecognizerSubclass

struct MusicEditView: View {
    @Binding var MusicTitle:String
    @Binding var MusicBar:Int
    
    @State var action:Int? = nil
    
    @Environment(\.undoManager) private var undoManage
    
    @State private var canvasView = PKCanvasView(frame: .init(x:0, y:0, width:250.0, height: 100.0))
    
    let imgRect = CGRect(x:0, y:0, width:250.0, height:100.0)
    
    let today = Date()
    var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
    }
    
    var myCanvasView: some View{
        CanvasView()
            .frame(width: 250.0, height: 100.0, alignment: .leading)
            .border(Color.gray, width:5)
    }
    
    var body: some View {
            ZStack{
                VStack{
                    HStack{
                        //MyCanvas(canvasView: $canvasView)
                        myCanvasView
                        /*
                        Button(action:
                        {
                            self.saveSignature()
                        })
                        {
                            Text("Save Signature")
                        }
                        */
                        Button("Save to image"){
                            print("Save button tapped")
                            let image = myCanvasView.snapshot()
                            
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                    }
                }
                /*
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged{ _ in
                        }
                        .onEnded{ _ in
                            print("Hi")
                        }
                )*/
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Clear") {
                            canvasView.drawing = PKDrawing()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Undo") {
                            undoManage?.undo()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Redo") {
                            undoManage?.redo()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("New") {}
                    }
                }
            }
    }
    //PKPencilkit 사용시 그려진 이미지 저장 코드
    /*
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveSignature(){
        let image = canvasView.drawing.image(from: imgRect, scale: 1.0)
        if let data = image.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("\(self.dateFormatter.string(from: self.today)).png")
            try? data.write(to: filename)
            print(filename)
        }
    }
    */
}

//PencilKit 사용시 UIKit 연동 코드
/*
struct MyCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        return canvasView
    }

    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {}
}
 */

//UIView 사용시 UIKit 연동 코드
struct CanvasView : UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return Canvas()
    }
        func updateUIView(_ canvasUIView: UIView, context: Context) {
        canvasUIView.backgroundColor = .white
    }
}

//UIView 사용시 Canvas overriding 코드
class Canvas: UIView {
    
    override func draw(_ rect: CGRect){
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        paths.forEach { path in
            switch(path.type) {
            case .move:
                context.move(to: path.point)
                break
            case .line:
                context.addLine(to: path.point)
                break
            }
        }
        
        context.setLineWidth(10)
        context.setLineCap(.round)
        context.strokePath()
    }
    
    var paths = [Path]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        paths.append(Path(type: .move, point: point))
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        paths.append(Path(type: .line, point: point))
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Hello")
    }
}

class Path {
    let type: PathType
    let point: CGPoint
    
    init(type: PathType, point: CGPoint) {
        self.type = type
        self.point = point
    }
    
    enum PathType {
        case move
        case line
    }
}

//Preview
struct MusicEditView_Previews: PreviewProvider {
    static var previews: some View {
        MusicEditView(MusicTitle: .constant("Sample Music Title"), MusicBar: .constant(1))
    }
}

//UIView 저장을 위한 View Extension + Snapshot 함수 구현
extension View{
    func snapshot() -> UIImage {
            let controller = UIHostingController(rootView: self)
            let view = controller.view

            let targetSize = controller.view.intrinsicContentSize
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            view?.backgroundColor = .clear

            let renderer = UIGraphicsImageRenderer(size: targetSize)

            return renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
}

extension UIView{
    func takeScreenshot() -> UIImage {
             // Begin context
          UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
             // Draw view in that context
             drawHierarchy(in: self.bounds, afterScreenUpdates: true)
             // And finally, get image
         let image = UIGraphicsGetImageFromCurrentImageContext()
             UIGraphicsEndImageContext()
             if (image != nil) {
                 return image!
             }
             return UIImage()
    }
}
