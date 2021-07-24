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
                                HStack{
                                    Text("Title")
                                    TextField("Input Your Music Title", text: $MusicTitle)
                                        .padding()
                                        .overlay(
                                            Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.black),
                                            alignment: .bottom
                                        )
                                }
                                HStack{
                                    Text("How Many bars?")
                                    Picker(selection: $MusicBar, label: Text("Choose your bars"), content: {
                                        ForEach(0..<21){
                                            v in Text(String(format: "%02d", v))
                                        }
                                    })
                                }
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        self.ShowNewMusic = false
                                    }, label: {
                                        Text("Close")
                                    })
                                    Spacer()
                                    Button(action: {
                                        self.ShowNewMusic = false
                                        self.action = 1
                                    }, label: {
                                        Text("Create")
                                    })
                                    Spacer()
                                }
                            }.padding()
                        }
                        .frame(width: 500, height: 400)
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
        Text("Navi Items")
            .navigationTitle("MusicListView")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    HStack{
                                        Button(action: {
                                            print("Button pressed")
                                        }) {
                                            Image(systemName: "plus.square.fill.on.square.fill")
                                                .imageScale(.medium)
                                        }
                                        Button(action: {
                                            print("Button pressed")
                                            ShowNewMusic = true
                                        }) {
                                            Text("New")
                                        }
                                    }
            )
    }
}

struct MusicList: View {
    var body: some View {
        List {
            Text("1")
            Text("2")
            Text("3")
        }.padding()
    }
}
