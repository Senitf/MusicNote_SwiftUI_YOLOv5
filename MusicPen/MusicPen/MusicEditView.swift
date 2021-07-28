//
//  MusicEditView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/22.
//

import SwiftUI
import PencilKit

struct MusicEditView: View {
    @Binding var MusicTitle:String
    @Binding var MusicBar:Int
    
    @State var action:Int? = nil
    
    @Environment(\.undoManager) private var undoManage
    
    @State private var canvasView = PKCanvasView(frame: .init(x:0, y:0, width:400.0, height: 100.0))
    
    let imgRect = CGRect(x:0, y:0, width:400.0, height:100.0)
    
    let today = Date()
    var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
    }
    
    var body: some View {
            ZStack{
                VStack{
                    MyCanvas(canvasView: $canvasView)
                        .frame(width: 400.0, height: 100.0, alignment: .leading)
                        .border(Color.gray, width:5)
                        .gesture(
                            DragGesture(minimumDistance: 0.1)
                                .onChanged{ _ in
                                    print("OH")
                                }
                                .onEnded{ _ in
                                    print("Hi")
                                }
                        )
                    Button(action:
                    {
                        self.saveSignature()
                    })
                    {
                        Text("Save Signature")
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded{ _ in
                            print("End")
                        }
                )
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
}

struct MusicEditView_Previews: PreviewProvider {
    static var previews: some View {
        MusicEditView(MusicTitle: .constant("Sample Music Title"), MusicBar: .constant(1))
    }
}

struct MyCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvasView.ge
        
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        if !canvasView.drawing.strokes.isEmpty {
             // set color whichever needed
             print("Hello")  // << here !!
        }
    }
}
