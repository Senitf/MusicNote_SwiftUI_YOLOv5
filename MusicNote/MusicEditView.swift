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
        if let filePath = Bundle.main.path(forResource: "YOLOv5_MusicNote", ofType: "pt"),
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
    @State var MusicBar:Int = 1
    
    //@State var stateMusicBar:Int = $MusicBar
    
    @State private var showingPopover = false
    
    @State var currentBar:Int = -1

    @Environment(\.undoManager) private var undoManage
    
    @State private var canvasView = PKCanvasView(frame: .init(x:0, y:0, width:400.0, height: 100.0))
    
    @State var outputImage:Image?
    @State var outputUIImage:UIImage?
    @State var imageList:[[UIImage]] = [[UIImage(named:"clefgTrans3.png")!, UIImage(named:"trans.png")!, UIImage(named:"trans.png")!, UIImage(named:"trans.png")!]]
    
    @State var curI:Int = -1
    @State var curJ:Int = -1
    
    @State var clearMode = false
    
    
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
                            //canvasView.drawing = PKDrawing()
                            clearMode.toggle()
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
                            self.add()
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
                        ForEach(0 ..< MusicBar, id: \.self){ i in
                            HStack{
                                ForEach(0..<4, id: \.self){ j in
                                    ZStack{
                                        Image(uiImage: imageList[i][j])
                                            .frame(width: 320.0, height: 100.0, alignment: .center)
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
                                        .onTapGesture {
                                            curI = i
                                            curJ = j
                                            if clearMode {
                                                if curJ == 0 {
                                                    imageList[curI][curJ] = UIImage(named: "clefgTrans3.png")!
                                                }
                                                else {
                                                    imageList[curI][curJ] = UIImage(named: "trans.png")!
                                                }
                                            }
                                            else{
                                                if showingPopover {
                                                    currentBar = i * 4 + j
                                                    imageList[curI][curJ] = self.saveSignature()
                                                }
                                                
                                                else {
                                                    currentBar = i * 4 + j
                                                    outputImage = nil
                                                    canvasView.drawing = PKDrawing()
                                                }
                                                showingPopover.toggle()
                                            }
                                        }
                                    }
                                    .frame(width: 320.0, height: 100.0)
                                    .padding(.leading, -75)
                                }
                            }
                        }
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
                        imageList[curI][curJ] = self.saveSignature()
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
    

    func add() -> Void {
        // store result string (must be on main queue)
        self.imageList.append([UIImage(named:"clefgTrans3.png")!, UIImage(named:"trans.png")!, UIImage(named:"trans.png")!, UIImage(named:"trans.png")!])
    }
    
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
    
    func saveSignature() -> UIImage{
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
            let filename = getDocumentsDirectory().appendingPathComponent("\(self.dateFormatter.string(from: self.today)).png")
            try? data.write(to: filename)
            guard var pixelBuffer:[Float32] = image.normalized() else {
                print("exception 1")
                return UIImage(named: "blank.png")!
            }

            guard let outputs = inferencer.module.detect(image: &pixelBuffer) else {
                print("exception 2")
                return UIImage(named: "blank.png")!
            }
            
            imageView?.image = image
            
            let nmsPredictions = PrePostProcessor.outputsToNMSPredictions(
                outputs: outputs, imgScaleX: imgScaleX, imgScaleY: imgScaleY, ivScaleX: ivScaleX, ivScaleY: ivScaleY, startX: startX, startY: startY
            )
            print(nmsPredictions)
            var result:UIImage = imageList[curI][curJ]

            for pred in nmsPredictions {
                var tmpImage = UIImage(named:String(pred.classIndex))
                tmpImage = tmpImage!.resized(to: CGSize(width: 50, height: 83))
                let originY = CGFloat(((((Int(pred.rect.maxY) - 20) / 20) * 10) + 10) - 64)
                let resultRect = CGRect(x:pred.rect.origin.x / 2, y: originY, width: 30, height:60)
                result = mergeImg(lhs: result, rhs: tmpImage!, rect: resultRect)
            }
            //return Image(uiImage: result)
            return result
        }
        print("exception 3")
        return UIImage(named: "blank.png")!
    }
    
    func createPdf() {
        let outputFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("yourFileName.pdf")
        let title = "Your Title\n"
        let text = String(repeating: "Your string row from List View or ScrollView \n ", count: 2000)

        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 36)]
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]

        let formattedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
        let formattedText = NSAttributedString(string: text, attributes: textAttributes)
        formattedTitle.append(formattedText)

        // 1. Create Print Formatter with your text.

        let formatter = UISimpleTextPrintFormatter(attributedText: formattedTitle)

        // 2. Add formatter with pageRender

        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)

        // 3. Assign paperRect and printableRect

        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)

        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")

        // 4. Create PDF context and draw
        let rect = CGRect.zero

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, rect, nil)

        for i in 1...render.numberOfPages {

            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }

        UIGraphicsEndPDFContext();

        // 5. Save PDF file

        do {
            try pdfData.write(to: outputFileURL, options: .atomic)

            print("wrote PDF file with multiple pages to: \(outputFileURL.path)")
        } catch {

             print("Could not create PDF file: \(error.localizedDescription)")
        }
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
        MusicEditView(MusicTitle: .constant("Sample Music Title"))
    }
}
