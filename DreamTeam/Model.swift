//
//  Model.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 12/15/20.
//

import Foundation
import Combine

class SceneManager: ObservableObject {
    @Published var state: String {
        didSet {
            UserDefaults.standard.set(state, forKey: "state")
        }
    }
    init() {
        self.state = UserDefaults.standard.string(forKey: "state") ?? ""
    }
}

class FeedResponse: Codable {
    
    let count: Int
    let tasks: [Task]
}

class AuthResponse: Codable {
    
    var authenticated: Bool = false
}

class UserSigninConfirm: Codable {
    
    var token: String = ""
    var userId: Int = 0
}

class Task: Codable, Identifiable {
    
    let id: Int
    let title: String
    let type: String
    let completed: String?
    let skipped: String?
    let deleted: String?
    let due: String
}

class TeamsResponse: Codable {
    
    let count: Int
    let teams: [Team]
}

class Team: Codable, Identifiable {
    
    var id: Int?
    var title: String
    
    init(id: Int?, title: String) {
        self.id = id
        self.title = title
    }
}

class MembersResponse: Codable {
    
    let count: Int
    let users: [User]
}

class User: Codable, Identifiable {
    
    var id: Int
    var username: String
    var is_deleted: Bool
    var token: String
}

class UserSettings: ObservableObject {
    
    @Published var id: Int {
        didSet {
            UserDefaults.standard.set(id, forKey: "id")
        }
    }
    
    @Published var token: String {
        didSet {
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    
    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "name")
        }
    }
    
    @Published var email: String {
        didSet {
            UserDefaults.standard.set(email, forKey: "email")
        }
    }
    
    //@Published var signedIn = false
    
    var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
    
    init() {
        self.id = UserDefaults.standard.integer(forKey: "id")
        self.token = UserDefaults.standard.string(forKey: "token") ?? ""
        self.name = UserDefaults.standard.string(forKey: "name") ?? ""
        self.email = UserDefaults.standard.string(forKey: "email") ?? ""
    }
}

struct ScheduleDay {
    var day: String
    var selected: Bool
}

struct Timing: Identifiable {
    var id: Int
    var text: String
    
    
    init(id: Int, text: String) {
        self.id = id
        self.text = text
    }
}
