//
//  FeedbackView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 3/2/21.
//

import SwiftUI

struct FeedbackView: View {
    
    @ObservedObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userFeedback: String = ""
    
    var body: some View {
        VStack {
        
            Form {
                
                Section {
                    Text("Hi there, I'm Lauren, the developer of this app. I'd love to get any feedback, feature requests or ideas you have to make it better. Cheers!")
                        .foregroundColor(.black)
                }
                
                Section(header: Text("Your Feedback / Requests / Ideas")) {
                    TextEditor( text: $userFeedback)
                        .frame(height: 100)
                        .keyboardType(.default)
                }
                
                Button("Send") {
                    sendFeedback()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarTitle("Feedback", displayMode: .inline)
    }
    
    func sendFeedback() {
        let url = URL(string: "http://34.208.204.33:8080/users/feedback?token=" + "\(userSettings.token)")!
        var request = URLRequest(url: url)

        let parameters: [String: Any] = [
            "feedback": userFeedback
        ]
        print(parameters)
        
        request.httpMethod = "POST"
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("No valid response")
                return
            }
            
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                print("Error: \(httpResponse.statusCode)")
                // Create alert for user and send back to edit email field
                return
            }
        }.resume()
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView(userSettings: UserSettings())
    }
}
