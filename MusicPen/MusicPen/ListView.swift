//
//  ListView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/21.
//

import SwiftUI

struct ListView: View {
    var body: some View {
        List {
            Text("1")
            Text("2")
            Text("3")
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
