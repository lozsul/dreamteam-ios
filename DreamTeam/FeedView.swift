//
//  ContentView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 12/15/20.
//

import SwiftUI


struct FeedView: View {
    
    @ObservedObject var userSettings = UserSettings()
    
    @State var array = [Task]()
    @State var isLoading: Bool = true
    
    // Register notification observer to refresh feed
    let pub = NotificationCenter.default.publisher(for: NSNotification.Name("FeedRefresh"))
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                if isLoading == true {
                    ProgressView()
                } else if array.count == 0 {
                    VStack {
                        
                        Text("No tasks yet")
                            .frame(width: geo.size.width, height: geo.size.height)
                            .foregroundColor(Color(.systemGray5))
                            .font(.largeTitle)
                        
                    }
                } else {
                    ZStack (alignment: .top) {
                        ScrollView {
                            LazyVStack(spacing: 1) {
                                ForEach (0..<array.count, id: \.self) { index in
                                    TaskView(task: array[index])
                                        .frame(height: 50)
                                        .padding(5)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(5)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    ToolbarView()
                }
            }
        }
        .onAppear(perform: loadUser)
        .onReceive(pub) { (output) in // Recieve notifications to refresh feed
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            loadData()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadUser() {
        if userSettings.id == 0 {
            // Create user

            let url = URL(string: "http://34.208.204.33:8080/users")!
            var request = URLRequest(url: url)

            let parameters: [String: Any] = [
                "timezone": userSettings.localTimeZoneIdentifier
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
                            userSettings.token = response.token
                            userSettings.id = response.id
                        }

                        return
                    }
                }
            }
            .resume()
        }

        loadData()
    }
    
    func loadData() {
        // Start loading
        isLoading = true
        
        let userid = UserDefaults.standard.integer(forKey: "id")
        
        guard let url = URL(string: "http://34.208.204.33:8080/feed?user_id=" + "\(userid)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
              do {
                let response = try JSONDecoder().decode(FeedResponse.self, from: data)
                DispatchQueue.main.async {
                    self.array = response.tasks
                    isLoading = false // End loading
                 }
              } catch let jsonError as NSError {
                print("\(jsonError.localizedDescription)")
              }
              return
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}


