//
//  MusicNoteApp.swift
//  MusicNote
//
//  Created by 김민호 on 2021/09/26.
//

import SwiftUI
import Firebase


@main
struct MusicNoteApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            //LoginView()
            MusicEditView(MusicTitle: .constant("Sample Music Title"), MusicBar: .constant(10))
            //testView()
        }
    }
}
