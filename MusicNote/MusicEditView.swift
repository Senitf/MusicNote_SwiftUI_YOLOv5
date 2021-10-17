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
import FirebaseDatabase

class ObjectDetector {

    lazy var module: InferenceModule = {
        if let filePath = Bundle.main.path(forResource: "model640x640", ofType: "pt"),
        //if let filePath = Bundle.main.path(forResource: "model", ofType: "pt"),
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
    
    //@State var stateMusicBar:Int = $MusicBar
    
    @State private var showingPopover = false
    
    @State var currentBar:Int = -1

    @Environment(\.undoManager) private var undoManage
    
    @State private var canvasView = PKCanvasView(frame: .init(x:0, y:0, width:400.0, height: 100.0))
    
    @State var outputImage:Image?
    @State var outputUIImage:UIImage?
    
    //lazy var rootRef = Database.database().reference()
    
    let imgRect = CGRect(x:0, y:0, width:640.0, height:640.0)
    
    var ref: DatabaseReference! = Database.database().reference()
    
    
    
    let today = Date()
    var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
    }
    
    var body: some View {
            ZStack{
                VStack{
                    //메뉴 바 항목들
                    HStack{
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
                            MusicBar += 1
                            //self.add()
                        }
                        .foregroundColor(Color.black)
                        .font(Font.custom("Multilingual Hand", size: 20))
                    }
                    .frame(minWidth: 0, maxWidth: 800, minHeight: 0, maxHeight: 30)
                    .padding(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1))
                    ScrollView(showsIndicators: false){
                        //악보 타이틀
                        Text(MusicTitle)
                            .font(Font.custom("Multilingual Hand", size: 32))
                            .padding(20)
                        ForEach(0 ..< MusicBar, id: \.self){ i in
                            HStack{
                                ForEach(0 ..< 4, id: \.self){ j in
                                    ZStack{
                                        /*
                                        currentBar = 0
                                        if outputUIImage = self.loadImageFromDocumentDirectory(fileName: "\(MusicTitle)_\(currentBar)"){
                                            Image(uiImage: outputUIImage)
                                        }
                                         */
                                        Path { path in
                                            path.move(to: CGPoint(x:0, y:10))
                                            path.addLine(to: CGPoint(x:320, y:10))
                                            path.move(to: CGPoint(x:0, y:30))
                                            path.addLine(to: CGPoint(x:320, y:30))
                                            path.move(to: CGPoint(x:0, y:50))
                                            path.addLine(to: CGPoint(x:320, y:50))
                                            path.move(to: CGPoint(x:0, y:70))
                                            path.addLine(to: CGPoint(x:320, y:70))
                                            path.move(to: CGPoint(x:0, y:90))
                                            path.addLine(to: CGPoint(x:320, y:90))
                                            path.move(to: CGPoint(x:320, y:10))
                                            path.addLine(to: CGPoint(x:320, y:90))
                                        }
                                        .stroke(Color.black, lineWidth: 2)
                                        .frame(width: 320.0, height: 100.0, alignment: .center)
                                        .tag(i * 4 + j)
                                        .onTapGesture {
                                            if showingPopover {
                                                currentBar = i * 4 + j
                                                outputImage = self.saveSignature()
                                            }
                                            
                                            else {
                                                currentBar = i * 4 + j
                                                outputImage = nil
                                                canvasView.drawing = PKDrawing()
                                            }
                                            showingPopover.toggle()
                                        }
                                    }

                                    .padding(.leading, -75)
                                    /*
                                    .padding(.bottom, 10)
                                     */
                                }
                            }
                        }
                        /*
                        outputImage?
                            .resizable()
                            .border(Color.gray, width:5)
                            .frame(width: 640, height: 640, alignment: .center)
                        */
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
                        showingPopover.toggle()
                    }
                }
                if showingPopover {
                    ZStack{
                        MyCanvas(canvasView: $canvasView)
                            .frame(width: 640.0, height: 200.0, alignment: .leading)
                            .background(Color.white.opacity(0))
                            .padding(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 7)
                        Path { path in
                            path.move(to: CGPoint(x:0, y:20))
                            path.addLine(to: CGPoint(x:640, y:20))
                            path.move(to: CGPoint(x:0, y:60))
                            path.addLine(to: CGPoint(x:640, y:60))
                            path.move(to: CGPoint(x:0, y:100))
                            path.addLine(to: CGPoint(x:640, y:100))
                            path.move(to: CGPoint(x:0, y:140))
                            path.addLine(to: CGPoint(x:640, y:140))
                            path.move(to: CGPoint(x:0, y:180))
                            path.addLine(to: CGPoint(x:640, y:180))
                            /*
                            path.move(to: CGPoint(x:640, y:20))
                            path.addLine(to: CGPoint(x:640, y:180))
                            */
                        }
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 640, height: 200.0, alignment: .center)
                    }
                    .background(Color.white)
                }
            }
    }
    
    /*
    func add() -> Void {
        // store result string (must be on main queue)
        self.imageList.append(UIImage(named:"trans.png")!)
        self.imageList.append(UIImage(named:"trans.png")!)
        self.imageList.append(UIImage(named:"trans.png")!)
        self.imageList.append(UIImage(named:"trans.png")!)
    }
     */
    
    public static func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {
            
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileURL
        }
        return nil
    }
    
    public static func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
            
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
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
        
        if let data = image.pngData(){
        //if let data = image.pngData() {
            
            let filename = getDocumentsDirectory().appendingPathComponent("\(self.dateFormatter.string(from: self.today)).png")
            try? data.write(to: filename)
            /*
            let resizedImage = image.resized(to: CGSize(width: 640, height: 640))
            print(filename)
             */
            guard var pixelBuffer:[Float32] = image.normalized() else {
                print("exception 1")
                return Image("blank")
            }

            guard let outputs = inferencer.module.detect(image: &pixelBuffer) else {
                print("exception 2")
                return Image("blank")
            }
            
            imageView?.image = image
            
            let nmsPredictions = PrePostProcessor.outputsToNMSPredictions(outputs: outputs, imgScaleX: imgScaleX, imgScaleY: imgScaleY, ivScaleX: ivScaleX, ivScaleY: ivScaleY, startX: startX, startY: startY)
            //let result = PrePostProcessor.showDetection(imageView: imageView!, nmsPredictions: nmsPredictions, classes: inferencer.classes)
            
            print(nmsPredictions)
            //print(inferencer.classes)
            
            var result:UIImage = UIImage(named: "trans.png")!
            //result = result.resized(to: CGSize(width:320, height: 100))
            
            for pred in nmsPredictions {
                var tmpImage = UIImage(named:String(pred.classIndex))
                tmpImage = tmpImage!.resized(to: CGSize(width: 50, height: 83))
                let originY = CGFloat(((((Int(pred.rect.maxY) - 20) / 20) * 10) + 10) - 64)
                let resultRect = CGRect(x:pred.rect.origin.x / 2, y: originY, width: 30, height:60)
                result = mergeImg(lhs: result, rhs: tmpImage!, rect: resultRect)
            }
            
            return Image(uiImage: result)
        }
        print("exception 3")
        return Image("blank")
    }
}

struct MyImage: View{
    @Binding var myUIImage:UIImage
    var body: some View{
        return Image(uiImage: myUIImage)
    }
}

struct TagView: UIViewRepresentable {
    let tag: Int

    func makeUIView(context: Context) -> UIView {
        let mainView = UIView()
        let uiImageView = UIImageView()
        let uiImage = UIImage(named: "trans.png")
        uiImageView.image = uiImage
        mainView.addSubview(uiImageView)
        mainView.tag = tag
        return mainView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.tag = tag
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
