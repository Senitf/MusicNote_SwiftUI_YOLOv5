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
    
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
            ZStack{
                VStack{
                    MyCanvas(canvasView: $canvasView)
                }
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
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) { }
}
