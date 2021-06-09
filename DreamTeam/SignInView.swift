//
//  SignInView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 3/2/21.
//

import SwiftUI

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}

struct SignInView: View {
    
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userId: String = ""
    @State private var userToken: String = ""
    @State private var userCode: String = ""
    @State private var isCodeSent: Bool = false
    
    @ObservedObject var userSettings = UserSettings()
    @EnvironmentObject var sceneManager: SceneManager
    
    var userType: [String] = ["Sign up", "Sign in"]
    @State private var defaultUserType = 0
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        GeometryReader {_ in
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Form {
                    Section {
                        Picker("", selection: $defaultUserType) {
                            ForEach(0 ..< userType.count) {
                                Text("\(self.userType[$0])")
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Sign up
                    if defaultUserType == 0 {
                        
                        Section {
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .frame(width: 30)
                                TextField("Name", text: $userName)
                            }
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .frame(width: 30)
                                TextField("Email", text: $userEmail)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                        }
                        
                        Section {
                            HStack(alignment: .center) {
                                Spacer()
                                Button(action: {
                                    signUp()
                                }) {
                                    Text("Sign up")
                                        .foregroundColor(.white)
                                        .padding(.vertical)
                                        .padding(.horizontal, 50)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                }
                                Spacer()
                            }
                        }
                        .disabled(userName.isEmpty || !userEmail.isValidEmail)
                        
                    // Sign in
                    } else {
                        if isCodeSent == false {
                            
                            Section {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .frame(width: 30)
                                    TextField("Email", text: $userEmail)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                            }
                            
                            Section {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isCodeSent = true
                                        getCode()
                                    }) {
                                        Text("Send code")
                                            .foregroundColor(.white)
                                            .padding(.vertical)
                                            .padding(.horizontal, 50)
                                            .background(Color.blue)
                                            .clipShape(Capsule())
                                    }
                                    Spacer()
                                }
                            }
                            .disabled(!userEmail.isValidEmail)
                            
                        } else {
                        
                            Section {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .frame(width: 30)
                                    TextField("One time code", text: $userCode)
                                        .keyboardType(.numberPad)
                                }
                            }
                            
                            Section {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        signIn()
                                        isCodeSent = false
                                    }) {
                                        Text("Sign in")
                                            .foregroundColor(.white)
                                            .padding(.vertical)
                                            .padding(.horizontal, 50)
                                            .background(Color.blue)
                                            .clipShape(Capsule())
                                    }
                                    Spacer()
                                }
                            }
                            .disabled(userCode.isEmpty)
                            
                            Section {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isCodeSent = true
                                        getCode()
                                    }) {
                                        Text("Re-send code?")
                                            .font(.caption)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 50)
        }
    }
    
    func signUp() {
        // Create user
        print("New user")

        let url = URL(string: "http://34.208.204.33:8080/users")!
        var request = URLRequest(url: url)

        let parameters: [String: Any] = [
            "timezone": userSettings.localTimeZoneIdentifier,
            "username": userName,
            "email": userEmail
        ]

        request.httpMethod = "POST"

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try?
                    JSONDecoder().decode(User.self, from: data) {
                    DispatchQueue.main.async {
                        userSettings.id = response.id
                        userSettings.token = response.token
                        userToken = response.token
                        userSettings.name = userName
                        userSettings.email = userEmail
                        sceneManager.state = "Signed In"
                        print(sceneManager.state)
                        
                        // Dismissing the keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    return
                }
            }
        }
        .resume()
    }
    
    func getCode() {
        // User adds email, we send an email with code/token
        
        // Setting the URL we want to read
        guard let url = URL(string: "http://34.208.204.33:8080/users/signin?email=" + "\(userEmail)") else {
            print("Invalid URL")
            return
        }
        // Wrapping it in a URLRequest
        let request = URLRequest(url: url)

        // Establish a network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("No valid response")
                return
            }
            
            if 200 ..< 300 ~= httpResponse.statusCode {
                DispatchQueue.main.async {
                    // Set UserSettings
                    userSettings.email = userEmail
                }
            } else {
                print("Error: \(httpResponse.statusCode)")
                // Create alert for user and send back to edit email field
                return
            }
        }.resume()
    }
    
    func signIn() {
        
        print("sign in")
        // Sign user in after inputting correct code
        // Setting the URL we want to read
        guard let url = URL(string: "http://34.208.204.33:8080/users/signin/confirm?email=" + "\(userEmail)" + "&code=" + "\(userCode)") else {
            print("Invalid URL")
            return
        }
        // Wrapping it in a URLRequest
        let request = URLRequest(url: url)

        // Establish a network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Closure inside the data task (responsible for doing something with the data or error)
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(UserSigninConfirm.self, from: data)
                    print(response)
                    DispatchQueue.main.async {
                        // Set UserSettings
                        userSettings.token = response.token
                        userSettings.id = response.userId
                        userToken = userSettings.token
                        
                        print(userSettings.id)
                        print(userSettings.name)
                        print(userSettings.email)
                        print(userSettings.token)
                        
                        // Send to FeedView
                        sceneManager.state = "Signed In"
                        
                        // Refresh feed
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("FeedRefresh"), object: nil)
                        }
                    }
                } catch let jsonError as NSError {
                    print("\(jsonError.localizedDescription)")
                }
              return
            }
        }.resume()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
