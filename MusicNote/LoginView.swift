//
//  ContentView.swift
//  MusicPen
//
//  Created by 김민호 on 2021/07/20.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
let storedUsername = "Seni"
let storedPassword = "qwe123"

class ViewModel {
    func login(){
        
    }
}

class User {
    var uid: String
    var email: String?
    var displayName: String?

    init(uid: String, displayName: String?, email: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }

}

class SessionStore : ObservableObject {
    var didChange = PassthroughSubject<SessionStore, Never>()
    var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?

    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.session = User(
                    uid: user.uid,
                    displayName: user.displayName,
                    email: user.email
                )
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
        }
    }
    
    func signUp(
            email: String,
            password: String,
            handler: @escaping AuthDataResultCallback
            ) {
            Auth.auth().createUser(withEmail: email, password: password, completion: handler)
        }

        func signIn(
            email: String,
            password: String,
            handler: @escaping AuthDataResultCallback
            ) {
            Auth.auth().signIn(withEmail: email, password: password, completion: handler)
        }

        func signOut () -> Bool {
            do {
                try Auth.auth().signOut()
                self.session = nil
                return true
            } catch {
                return false
            }
        }
    func unbind () {
            if let handle = handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
}

struct LoginView : View {
    
    @EnvironmentObject var session: SessionStore
    
    @State var username: String = ""
    @State var password: String = ""
    @State var signUpEmail: String = ""
    @State var signUpPassword: String = ""
    @State var isPopoverPresented: Bool = false
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    
    @State var action:Int? = nil
    
    @State var email: String = ""
    @State var loading = false
    @State var error = false
    
    func getUser () {
        session.listen()
    }
    
    func signIn () {
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
                if error != nil {
                    self.error = true
                } else {
                    self.email = ""
                    self.password = ""
            }
        }
    }
    
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
                        .padding(.bottom, 40)
                    EmailTextField(email: $email)
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
                        SignupButtonContent()
                    }
                    .popover(isPresented: $isPopoverPresented) {
                        VStack{
                            Spacer()
                            Text("SignUp")
                                .font(.largeTitle)
                            Spacer()
                            TextField("Username", text: $signUpEmail)
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
        .onAppear(perform: getUser)
    }
    
    func login(){
        Auth.auth().signIn(withEmail: self.email, password: self.password)
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
        Auth.auth().createUser(withEmail: self.signUpEmail, password: self.signUpPassword)
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

struct WelcomeText: View {
    var body: some View {
        Text("Music Note")
            .font(Font.custom("Multilingual Hand", size: 40))
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
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 7)
    }
}

struct LoginButtonContent: View {
    var body: some View {
        Text("SIGN IN")
            .font(Font.custom("Multilingual Hand", size: 20))
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height:60)
            .background(Color.gray)
            .cornerRadius(15.0)
    }
}

struct SignupButtonContent: View {
    var body: some View {
        Text("SIGN UP")
            .font(Font.custom("Multilingual Hand", size: 20))
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height:60)
            .background(Color.gray)
            .cornerRadius(15.0)
    }
}

struct EmailTextField: View {
    @Binding var email: String
    var body: some View {
        return TextField("Username", text: $email)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
            .frame(width:400)
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
            .frame(width:400)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionStore())
    }
}
