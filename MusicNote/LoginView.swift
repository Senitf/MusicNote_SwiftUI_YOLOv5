//
//  ContentView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/20.
//

import SwiftUI
import Firebase
import FirebaseAuth

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
let storedUsername = "Seni"
let storedPassword = "qwe123"

class ViewModel {
    func login(){
        
    }
}

struct LoginView : View {
    @State var username: String = ""
    @State var password: String = ""
    @State var signUpUsername: String = ""
    @State var signUpPassword: String = ""
    @State var isPopoverPresented: Bool = false
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    
    @State var action:Int? = nil
    
    var body: some View {
        NavigationView{
            ZStack{
                NavigationLink(
                    destination: MusicListView(),
                    tag: 1,
                    selection: $action) {EmptyView()}
                VStack{
                    WelcomeText()
                    UserImage()
                    UsernameTextField(username: $username)
                    PasswordSecureField(password: $password)
                    if authenticationDidFail {
                        Text("Information not correct. Try again.")
                            .offset(y: -10)
                            .foregroundColor(.red)
                    }
                    Button(action: {
                        print("Login button tapped")
                        self.login()
                        /*
                        if self.username == storedUsername && self.password == storedPassword {
                            self.authenticationDidSucceed = true
                            self.authenticationDidFail = false
                            self.action = 1
                        }
                        else {
                            self.authenticationDidFail = true
                        }
                        */
                    }){
                        LoginButtonContent()
                    }
                    Button(action: {
                        self.isPopoverPresented = true
                    }) {
                        Text("Show Popover")
                    }
                    .popover(isPresented: $isPopoverPresented) {
                        VStack{
                            Spacer()
                            Text("SignUp")
                                .font(.largeTitle)
                            Spacer()
                            TextField("Username", text: $signUpUsername)
                                .padding()
                                .background(lightGreyColor)
                                .cornerRadius(5.0)
                                .padding(.bottom, 20)
                            SecureField("Password", text: $signUpPassword)
                                .padding()
                                .background(lightGreyColor)
                                .cornerRadius(5.0)
                                .padding(.bottom, 20)
                            Button(action: self.signUp) {
                                Text("Register")
                            }
                        }
                        .padding()
                        .frame(width:500, height: 500)
                    }
                }
                .padding()
                if authenticationDidSucceed {
                    Text("Login succeeded!")
                        .font(.headline)
                        .frame(width: 250, height: 80)
                        .background(Color.green)
                        .cornerRadius(20.0)
                        .foregroundColor(.white)
                        .animation(Animation.default)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func login(){
        Auth.auth().signIn(withEmail: self.username, password: self.password)
        { (user, error) in
            if user != nil {
                print("login success")
                print(user)
                self.authenticationDidSucceed = true
                self.authenticationDidFail = false
                self.action = 1
            }
            else {
                print(error)
                self.authenticationDidFail = true
            }
        }
    }
    
    func signUp(){
        Auth.auth().createUser(withEmail: self.signUpUsername, password: self.signUpPassword)
        { (user, error) in
            if(user != nil){
                print("register successs")
                print(user)
            }
            else{
                print("register failed")
                
            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct WelcomeText: View {
    var body: some View {
        Text("Welcome!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage: View {
    var body: some View {
        Image(systemName:"person.fill")
            .resizable() //Sets the mode by which SwiftUI resizes an image to fit its space.
            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/) //Constrains this view’s dimensions to the aspect ratio of the given size.
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 7)
    }
}

struct LoginButtonContent: View {
    var body: some View {
        Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height:60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}

struct UsernameTextField: View {
    @Binding var username: String
    var body: some View {
        return TextField("Username", text: $username)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct PasswordSecureField: View {
    @Binding var password: String
    var body: some View {
        return SecureField("Password", text: $password)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}