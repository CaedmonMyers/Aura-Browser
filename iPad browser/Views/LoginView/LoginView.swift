//
//  LoginView.swift
//  iPad browser
//
//  Created by Caedmon Myers on 9/9/23.
//

import SwiftUI





struct LoginView: View {
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    
    @State var email = ""
    @State var password = ""
    
    @State var resetPassword = false
    @State var resetEmail = ""
    @State var resetSent = false
    @State var invalidError = false
    
    @AppStorage("email") var appIsLoggedIn: String = ""
    
    @State var incorrectPassword = false
    
    @State var onboarding = 1
    
    var body: some View {
        ZStack {
            if appIsLoggedIn.isEmpty {
                if onboarding == 1 {
                    page1
                }
                
                else if onboarding == 2 {
                    onboardingComingSoon
                    //page2
                }
                
                else if onboarding == 3 {
                    page3Login
                }
                
                else if onboarding == 4 {
                    page3SignUp
                }
            }
            else {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Mobile()
                }
                else {
                    ContentView()
                }
            }
        }
    }
    
    var page1: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "8A3CEF"), Color(hex: "84F5FE")], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Hello!")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                
                SizedSpacer(height: 20)
                
                
                Text("Let's get you set up")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                
                SizedSpacer(height: 100)
                
                
                Button {
                    onboarding = 2
                } label: {
                    ZStack {
                        Text("")
                    }
                }.buttonStyle(GrowingButton(buttonText: "Continue", buttonWidth: 225, buttonHeight: 30)).hoverEffect(.lift)
                
            }
        }
    }
    
    var onboardingComingSoon: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "8A3CEF"), Color(hex: "84F5FE")], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("New Onboarding Coming Soon")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                
                SizedSpacer(height: 100)
                
                
                Button {
                    appIsLoggedIn = "skip"
                } label: {
                    ZStack {
                        Text("")
                    }
                }.buttonStyle(GrowingButton(buttonText: "Continue", buttonWidth: 225, buttonHeight: 30)).hoverEffect(.lift)
                
                
            }//.frame(width: 350)
        }
    }
    
    
    var page2: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(hex: "8A3CEF"), Color(hex: "84F5FE")], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button {
                            onboarding -= 1
                        } label: {
                            ZStack {
                                Text("")
                            }
                        }.buttonStyle(GrowingButton(buttonText: "< Back", buttonWidth: 75, buttonHeight: 20))
                            .hoverEffect(.lift)
                            .padding(50)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 20) {
                    HStack {
                        Text("First,")
                            .foregroundColor(Color(.white))
                            .font(.system(size: 100, weight: .bold, design: .rounded))
                            .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                    }.frame(width: 500)
                    
                    SizedSpacer(height: 20)
                    
                    
                    Text("Do you already have an account?")
                        .foregroundColor(Color(.white))
                        .multilineTextAlignment(.center)
                        .frame(width: 500)
                        //.font(.system(size: 50, weight: .bold, design: .rounded))
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                    
                    
                    SizedSpacer(height: 75)
                    
                    
                    Button {
                        onboarding += 1
                    } label: {
                        Text("Yes :)")
                            .frame(width: geo.size.width/2, height: 30)
                    }.buttonStyle(NewButtonStyle(startHex: "8041E6", endHex: "A0F2FC"))
                        .hoverEffect(.lift)
                    
                    
                    Button {
                        onboarding += 2
                    } label: {
                        Text("Nope :(")
                            .frame(width: geo.size.width/2, height: 30)
                    }.buttonStyle(NewButtonStyle(startHex: "8041E6", endHex: "A0F2FC"))
                        .hoverEffect(.lift)
                    
                    Button {
                        appIsLoggedIn = "loginSkipped"
                    } label: {
                        Text("Skip :o")
                            .frame(width: geo.size.width/2, height: 30)
                    }.buttonStyle(NewButtonStyle(startHex: "8041E6", endHex: "A0F2FC"))
                        .hoverEffect(.lift)
                    
                    
                }//.frame(width: 350)
            }
        }
    }
    
    var page3Login: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "8A3CEF"), Color(hex: "84F5FE")], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        onboarding -= 1
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }.buttonStyle(NewButtonStyle(startHex: "8041E6", endHex: "A0F2FC"))
                        .hoverEffect(.lift)
                        .padding(50)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            VStack(spacing: 20) {
                Text("Login")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                ZStack {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                                .frame(height: 75)
                            
                            TextField("", text: $email)
                                .font(Font.body.weight(.bold))
                                .foregroundColor(Color(hex: "8880F5"))
                                .textFieldStyle(.plain)
                                .textInputAutocapitalization(.never)
                                .placeholder(when: email.isEmpty) {
                                    Text("Email")
                                        .foregroundColor(Color(hex: "8880F5"))
                                        .bold()
                                }
                                .padding(17)
                                .hoverEffect(.lift)
                            
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                                .frame(height: 75)
                            
                            SecureField("", text: $password)
                                .font(Font.body.weight(.bold))
                                .foregroundColor(Color(hex: "8880F5"))
                                .textFieldStyle(.plain)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password")
                                        .foregroundColor(Color(hex: "8880F5"))
                                        .bold()
                                }
                                .padding(17)
                                .hoverEffect(.lift)
                        }
                    }
                    
                }
                
                if invalidError && incorrectPassword == false {
                    ProgressView("Loading")
                }
                
                if incorrectPassword {
                    Text("Incorrect Password")
                        .foregroundStyle(Color.white)
                }
                
                Button {
                    //login()
                    
                    invalidError = true
                } label: {
                    ZStack {
                        Text("")
                    }.hoverEffect(.lift)
                }.buttonStyle(GrowingButton(buttonText: "Login", buttonWidth: 225, buttonHeight: 30))
                
                
                VStack {
                    if resetPassword == false {
                        Button {
                            resetPassword.toggle()
                        } label: {
                            Text("Forgot Password")
                                .bold()
                                .foregroundColor(Color(.white))
                                .hoverEffect(.highlight)
                        }
                    }
                    
                    else {
                        TextField("Email", text: $resetEmail)
                            .font(Font.body.weight(.bold))
                            .foregroundColor(Color(.white))
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .placeholder(when: resetEmail.isEmpty) {
                                Text("Email")
                                    .foregroundColor(Color(.white))
                                    .bold()
                            }
                            .hoverEffect(.lift)
                        
                        Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundColor(Color(.white))
                        
                        
                        Button {
                            //Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
                                // ...
                            //}
                        } label: {
                            Text("Send Reset Email")
                                .bold()
                                .foregroundColor(Color(.white))
                                .hoverEffect(.highlight)
                        }
                        
                        if resetSent {
                            Text("Request Sent")
                                .bold()
                                .foregroundColor(Color(.white))
                        }
                    }
                }//.offset(y: 110)
                
            }.frame(width: 350)
                /*.onAppear() {
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            appIsLoggedIn
                        }
                    }
                }*/
        }
    }
    
    
    var page3SignUp: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "8A3CEF"), Color(hex: "84F5FE")], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        onboarding -= 2
                    } label: {
                        ZStack {
                            Text("")
                        }.hoverEffect(.lift)
                    }.buttonStyle(GrowingButton(buttonText: "< Back", buttonWidth: 75, buttonHeight: 20))
                        .padding(50)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            VStack(spacing: 20) {
                Text("Create Account")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                ZStack {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                                .frame(height: 75)
                            
                            TextField("", text: $email)
                                .font(Font.body.weight(.bold))
                                .foregroundColor(Color(hex: "8880F5"))
                                .textFieldStyle(.plain)
                                .textInputAutocapitalization(.never)
                                .placeholder(when: email.isEmpty) {
                                    Text("Email")
                                        .foregroundColor(Color(hex: "8880F5"))
                                        .bold()
                                }
                                .padding(17)
                                .hoverEffect(.lift)
                        }
                        
                        /*Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundColor(Color(.white))*/
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                                .frame(height: 75)
                            
                            SecureField("", text: $password)
                                .font(Font.body.weight(.bold))
                                .foregroundColor(Color(hex: "8880F5"))
                                .textFieldStyle(.plain)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password")
                                        .foregroundColor(Color(hex: "8880F5"))
                                        .bold()
                                }
                                .padding(17)
                                .hoverEffect(.lift)
                        }
                    }
                    
                }
                
                Button {
                    //register()
                } label: {
                    ZStack {
                        Text("")
                    }.hoverEffect(.lift)
                }.buttonStyle(GrowingButton(buttonText: "Next", buttonWidth: 225, buttonHeight: 30))
                
                
                VStack {
                    if resetPassword == false {
                        Button {
                            resetPassword.toggle()
                        } label: {
                            Text("Forgot Password")
                                .bold()
                                .foregroundColor(Color(.white))
                                .hoverEffect(.highlight)
                        }
                    }
                    
                    else {
                        TextField("Email", text: $resetEmail)
                            .font(Font.body.weight(.bold))
                            .foregroundColor(Color(.white))
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .placeholder(when: resetEmail.isEmpty) {
                                Text("Email")
                                    .foregroundColor(Color(.white))
                                    .bold()
                            }
                            .hoverEffect(.lift)
                        
                        Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundColor(Color(.white))
                        
                        
                        Button {
                            //Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
                                // ...
                            //}
                        } label: {
                            Text("Send Reset Email")
                                .bold()
                                .foregroundColor(Color(.white))
                                .hoverEffect(.highlight)
                        }
                        
                        if resetSent {
                            Text("Request Sent")
                                .bold()
                                .foregroundColor(Color(.white))
                        }
                    }
                }//.offset(y: 110)
                
            }.frame(width: 350)
                /*.onAppear() {
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            appIsLoggedIn
                        }
                    }
                }*/
        }
    }
    
    
    func saveColor(color: Color, key: String) {
        let uiColor = UIColor(color)
        let hexString = uiColor.toHex()
        defaults.set(hexString, forKey: key)
    }
    
    func getColor(forKey key: String) -> Color? {
        guard let hexString = UserDefaults.standard.string(forKey: key) else {
            return nil
        }
        return Color(hex: hexString)
    }
    
    /*func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        defaults.set(email, forKey: "email")
        
        incorrectPassword = false
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                if (error as! AuthErrorCode).code == AuthErrorCode.wrongPassword {
                    // The password is incorrect.
                    print("Incorrect password.")
                    
                    incorrectPassword = true
                } else {
                    // Another error occurred.
                    print(error!.localizedDescription)
                }
            } else {
                // The user was successfully signed in.
                print("User signed in.")
                
                incorrectPassword = false
            }
        }
        
        
        defaults.set(email, forKey: "email")
    }*/
}




extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

