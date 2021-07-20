//
//  ContentView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/20.
//

import SwiftUI

struct AppTitle : View {
    var body : some View {
        VStack {
            Text("App Name")
                .font(.title)
                .fontWeight(.medium)
                .padding()
        }
        .frame(maxHeight:250, alignment: .center)
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                AppTitle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
