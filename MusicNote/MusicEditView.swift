//
//  MusicEditView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/22.
//

import UIKit
import SwiftUI
import PencilKit
import UIKit.UIGestureRecognizerSubclass
import Foundation
import Firebase

class ObjectDetector {

    lazy var module: InferenceModule = {
        if let filePath = Bundle.main.path(forResource: "model640x640", ofType: "pt"),
            let module = InferenceModule(fileAtPath: filePath) {
            return module
        }else {
            fatalError("Failed to load model!")
        }
    }()
    
    lazy var classes: [String] = {
        if let filePath = Bundle.main.path(forResource: "output", ofType: "txt"),
            let classes = try? String(contentsOfFile: filePath) {
            return classes.components(separatedBy: .newlines)
        } else {
            fatalError("classes file was not found.")
        }
    }()
}

struct MusicEditView: View {
    @Binding var MusicTitle:String
    @Binding var MusicBar:Int
    
    @State private var showingPopover = false
    
    @State var currentBar:Int = -1

    @Environment(\.undoManager) private var undoManage
    
    @State private var canvasView = PKCanvasView(frame: .init(x:0, y:0, width:400.0, height: 100.0))
    
    @State var outputImage:Image?
    
    //lazy var rootRef = Database.database().reference()
    
    let imgRect = CGRect(x:0, y:0, width:640.0, height:640.0)
    
    let today = Date()
    var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
    }
    
    var body: some View {
            ZStack{
                VStack{
                    HStack{ //메뉴 바 항목들
                        if currentBar == -1 {
                            Text("Current Bar : Not selected")
                                .font(Font.custom("Multilingual Hand", size: 20))
                        }
                        else {
                            Text("Current Bar : " + String(currentBar))
                                .font(Font.custom("Multilingual Hand", size: 20))
                        }
                        Spacer()
                        Button("Clear") {
                            canvasView.drawing = PKDrawing()
                        }
                        .foregroundColor(Color.black)
                        .font(Font.custom("Multilingual Hand", size: 20))
                        Button("Undo") {
                            undoManage?.undo()
                        }
                        .foregroundColor(Color.black)
                        .font(Font.custom("Multilingual Hand", size: 20))
                        Button("Redo") {
                            undoManage?.redo()
                        }
                        .foregroundColor(Color.black)
                        .font(Font.custom("Multilingual Hand", size: 20))
                        Button("New") {
                            
                        }
                        .foregroundColor(Color.black)
                        .font(Font.custom("Multilingual Hand", size: 20))
                    }
                    .frame(minWidth: 0, maxWidth: 800, minHeight: 0, maxHeight: 30)
                    .padding(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1))
                    ScrollView(showsIndicators: false){
                        Text(MusicTitle) //악보 타이틀
                            .font(Font.custom("Multilingual Hand", size: 32))
                            .padding(20)
                        ForEach(0 ..< MusicBar){ i in
                            HStack{
                                ForEach(0 ..< 4, id: \.self){ j in
                                    Path { path in
                                        path.move(to: CGPoint(x:0, y:10))
                                        path.addLine(to: CGPoint(x:250, y:10))
                                        path.move(to: CGPoint(x:0, y:30))
                                        path.addLine(to: CGPoint(x:250, y:30))
                                        path.move(to: CGPoint(x:0, y:50))
                                        path.addLine(to: CGPoint(x:250, y:50))
                                        path.move(to: CGPoint(x:0, y:70))
                                        path.addLine(to: CGPoint(x:250, y:70))
                                        path.move(to: CGPoint(x:0, y:90))
                                        path.addLine(to: CGPoint(x:250, y:90))
                                        path.move(to: CGPoint(x:250, y:10))
                                        path.addLine(to: CGPoint(x:250, y:90))
                                    }
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 250.0, height: 100.0, alignment: .center)
                                    .padding(.leading, -7)
                                    .padding(.bottom, 25)
                                    .tag(i * 4 + j)
                                    .onTapGesture {
                                        /*
                                        if showingPopover {
                                            outputImage = self.saveSignature()
                                        }
                                        
                                        else {
                                            currentBar = i * 4 + j
                                            outputImage = nil
                                            canvasView.drawing = PKDrawing()
                                        }
                                        showingPopover.toggle()
                                         */
                                        if !showingPopover{
                                            showingPopover = true
                                        }
                                        currentBar = i * 4 + j
                                        outputImage = nil
                                        canvasView.drawing = PKDrawing()
                                    }
                                }
                            }
                        }
                        outputImage?
                            .resizable()
                            .border(Color.gray, width:5)
                            .frame(width: 640, height: 640, alignment: .center)
                        Spacer()
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .background(Color.white)
                .contentShape(Rectangle())
                .onTapGesture {
                    if showingPopover {
                        outputImage = self.saveSignature()
                    }
                    else {
                        outputImage = nil
                        canvasView.drawing = PKDrawing()
                    }
                    showingPopover.toggle()
                }
                if showingPopover {
                    ZStack{
                        MyCanvas(canvasView: $canvasView)
                            .frame(width: 640.0, height: 160.0, alignment: .leading)
                            .background(Color.white.opacity(0))
                            .padding(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 2))
                        Path { path in
                            path.move(to: CGPoint(x:0, y:10))
                            path.addLine(to: CGPoint(x:640, y:10))
                            path.move(to: CGPoint(x:0, y:45))
                            path.addLine(to: CGPoint(x:640, y:45))
                            path.move(to: CGPoint(x:0, y:80))
                            path.addLine(to: CGPoint(x:640, y:80))
                            path.move(to: CGPoint(x:0, y:115))
                            path.addLine(to: CGPoint(x:640, y:115))
                            path.move(to: CGPoint(x:0, y:150))
                            path.addLine(to: CGPoint(x:640, y:150))
                            path.move(to: CGPoint(x:640, y:10))
                            path.addLine(to: CGPoint(x:640, y:150))
                        }
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 640.0, height: 160.0, alignment: .center)
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
    
    func saveSignature() -> Image{
        let inferencer = ObjectDetector()
        let image = canvasView.drawing.image(from: imgRect, scale: 1.0)
        var imageView:UIImageView?
        var tmpUIImage:UIImage?
        
        if let tmp = UIImage(named: "blank.png"){
            tmpUIImage = tmp
            imageView = UIImageView(image: tmpUIImage)
        }
        
        
        let imgScaleX = Double(image.size.width / CGFloat(PrePostProcessor.inputWidth))
        let imgScaleY = Double(image.size.height / CGFloat(PrePostProcessor.inputHeight))
        let ivScaleX : Double = (image.size.width > image.size.height ? Double(640.0 / image.size.width) : Double(640.0 / image.size.height))
        let ivScaleY : Double = (image.size.height > image.size.width ? Double(640.0 / image.size.height) : Double(640.0 / image.size.width))
        let startX = Double((640.0 - CGFloat(ivScaleX) * image.size.width)/2)
        let startY = Double((640.0 -  CGFloat(ivScaleY) * image.size.height)/2)
        
        /*
        let imgScaleX = 1.0
        let imgScaleY = 1.0
        let ivScaleX = 1.0
        let ivScaleY = 1.0
        let startX = 0.0
        let startY = 0.0
        */
        
        if let data = image.pngData(){
        //if let data = image.pngData() {
            
            let filename = getDocumentsDirectory().appendingPathComponent("\(self.dateFormatter.string(from: self.today)).png")
            try? data.write(to: filename)
            /*
            let resizedImage = image.resized(to: CGSize(width: 640, height: 640))
            print(filename)
            guard var pixelBuffer = resizedImage.normalized() else {
                print("exception 1")
                return Image("blank")
            }
             */
            guard var pixelBuffer = image.normalized() else {
                print("exception 1")
                return Image("blank")
            }
            guard let outputs = inferencer.module.detect(image: &pixelBuffer) else {
                print("exception 2")
                return Image("blank")
            }
            
            imageView?.image = image
            
            let nmsPredictions = PrePostProcessor.outputsToNMSPredictions(outputs: outputs, imgScaleX: imgScaleX, imgScaleY: imgScaleY, ivScaleX: ivScaleX, ivScaleY: ivScaleY, startX: startX, startY: startY)
            let result = PrePostProcessor.showDetection(imageView: imageView!, nmsPredictions: nmsPredictions, classes: inferencer.classes)
            
            print(nmsPredictions)
            //print(inferencer.classes)
            return Image(uiImage: result)
        }
        print("exception 3")
        return Image("blank")
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
        MusicEditView(MusicTitle: .constant("Sample Music Title"), MusicBar: .constant(2))
    }
}
