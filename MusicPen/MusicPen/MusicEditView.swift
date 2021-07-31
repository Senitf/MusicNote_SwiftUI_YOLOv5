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
    @State private var showingPopover = false

    @Environment(\.undoManager) private var undoManage
    
    @State private var canvasView = PKCanvasView(frame: .init(x:0, y:0, width:1000.0, height: 400.0))
    
    @State private var CanvasIdx:Int? = nil
    
    let imgRect = CGRect(x:0, y:0, width:1000.0, height:400.0)
    
    let today = Date()
    var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
    }
    
    var body: some View {
            ZStack{
                VStack{
                    ForEach(0 ..< MusicBar){ _ in
                        HStack{
                            ForEach(0 ..< 4, id: \.self){ _ in
                                SubUIView()
                                    .frame(width: 250.0, height: 100.0, alignment: .center)
                                    .border(Color.black)
                                    .padding(.leading, -7)
                                    .padding(.bottom, 25)
                            }
                        }
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Popover toggled")
                    if showingPopover {
                        self.saveSignature()
                        print("pic saved")
                    }
                    showingPopover.toggle()
                }
                if showingPopover {
                    VStack{
                        HStack{
                            Button("Clear") {
                                canvasView.drawing = PKDrawing()
                            }
                            Button("Undo") {
                                undoManage?.undo()
                            }
                            Button("Redo") {
                                undoManage?.redo()
                            }
                            Button("New") {}
                        }
                        MyCanvas(canvasView: $canvasView)
                            .frame(width: 1000.0, height: 400.0, alignment: .leading)
                            .border(Color.gray, width:5)
                    }
                    .background(Color.white)
                }
            }
    }
    //PKPencilkit 사용시 그려진 이미지 저장 코드
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

struct SubUIView: View {
    var body: some View {
        Text("Canvas Image Data")
    }
}

//PencilKit 사용시 UIKit 연동 코드
struct MyCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {}
}

//Preview
struct MusicEditView_Previews: PreviewProvider {
    static var previews: some View {
        MusicEditView(MusicTitle: .constant("Sample Music Title"), MusicBar: .constant(1))
    }
}
