//
//  MusicListView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/21.
//

import SwiftUI

struct MusicListView: View {
    
    @State var ShowNewMusic: Bool = false
    @State var MusicTitle: String = ""
    @State var MusicBar: Int = 0
    
    @State var action:Int? = nil
    
    var body: some View {
        NavigationView{
            ZStack{
                NavigationLink(
                    destination: MusicEditView(MusicTitle: $MusicTitle, MusicBar: $MusicBar),
                    tag: 1,
                    selection: $action)
                    {EmptyView()}
                NavigationBar(ShowNewMusic: $ShowNewMusic)
                VStack{
                    MusicList()
                }
                if ShowNewMusic {
                    ZStack {
                            Color.white
                            VStack {
                                Text("Create New Music")
                                    .foregroundColor(Color.black)
                                    .font(Font.custom("Multilingual Hand", size: 20))
                                Spacer()
                                HStack{
                                    Text("Title")
                                        .foregroundColor(Color.black)
                                        .font(Font.custom("Multilingual Hand", size: 20))
                                    TextField("Input Your Music Title", text: $MusicTitle)
                                        .padding(.bottom, 5)
                                        .overlay(
                                            Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.black),
                                            alignment: .bottom
                                        )
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        self.ShowNewMusic = false
                                        print("Close button tapped")
                                    }, label: {
                                        Text("Close")
                                            .foregroundColor(Color.black)
                                            .font(Font.custom("Multilingual Hand", size: 20))
                                    })
                                    Spacer()
                                    Button(action: {
                                        self.ShowNewMusic = false
                                        self.action = 1
                                        print("Create button tapped")
                                    }, label: {
                                        Text("Create")
                                            .foregroundColor(Color.black)
                                            .font(Font.custom("Multilingual Hand", size: 20))
                                    })
                                    Spacer()
                                }
                            }.padding()
                        }
                        .frame(width: 500, height: 200)
                        .cornerRadius(20).shadow(radius: 20)
                }
            }.padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}

struct MusicListView_Previews: PreviewProvider {
    static var previews: some View {
        MusicListView()
    }
}

struct NavigationBar: View {
    @Binding var ShowNewMusic: Bool
    var body: some View {
        Text("")
            .navigationBarTitle (Text("Your Notes"), displayMode: .inline)
            .navigationBarItems(trailing:
                HStack{
                    Button("Profile") {

                    }
                    .foregroundColor(Color.black)
                    .font(Font.custom("Multilingual Hand", size: 20))
                    Button("New") {
                        ShowNewMusic = true
                    }
                    .foregroundColor(Color.black)
                    .font(Font.custom("Multilingual Hand", size: 20))
                }
            )
    }
}

struct MusicList: View {
    var body: some View {
        VStack{
            Text("Sample Score 1")
                .frame(width: 1200, height: 70.0, alignment: .center)
                .font(Font.custom("Multilingual Hand", size: 20))
                .background(Color.white.opacity(0))
                .padding(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
                .padding(.bottom, 40)
            Text("Sample Score 2")
                .frame(width: 1200, height: 70.0, alignment: .center)
                .font(Font.custom("Multilingual Hand", size: 20))
                .background(Color.white.opacity(0))
                .padding(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
                .padding(.bottom, 40)
            Text("Test")
                .frame(width: 1200, height: 70.0, alignment: .center)
                .font(Font.custom("Multilingual Hand", size: 20))
                .background(Color.white.opacity(0))
                .padding(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
        }
    }
}
