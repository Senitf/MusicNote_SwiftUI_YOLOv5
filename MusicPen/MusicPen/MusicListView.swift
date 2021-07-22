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
    var body: some View {
        NavigationView{
            ZStack{
                NavigationBar(ShowNewMusic: $ShowNewMusic)
                VStack{
                    MusicList()
                }
                if ShowNewMusic {
                    ZStack {
                            Color.white
                            VStack {
                                Text("Create New Music")
                                Spacer()
                                HStack{
                                    Text("Title")
                                    TextField("Title", text: $MusicTitle)
                                }
                                Spacer()
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
                                    }, label: {
                                        Text("Create")
                                    })
                                    Spacer()
                                }
                            }.padding()
                        }
                        .frame(width: 300, height: 200)
                        .cornerRadius(20).shadow(radius: 20)
                }
            }.padding()
        }.navigationViewStyle(StackNavigationViewStyle())
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
            .navigationBarBackButtonHidden(true)
            .navigationTitle("MusicListView")
            .navigationBarItems(leading:
                                    Button(action: {
                                        print("Button pressed")
                                    }) {
                                        Image(systemName: "plus.square.fill.on.square.fill").imageScale(.medium)
                                    },
                                trailing:
                                    Button(action: {
                                        print("Button pressed")
                                        ShowNewMusic = true
                                    }) {
                                        Text("New")
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
