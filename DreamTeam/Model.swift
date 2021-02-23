//
//  Model.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 12/15/20.
//

import Foundation
import Combine

class FeedResponse: Codable {
    
    let count: Int
    let tasks: [Task]
}

class AuthResponse: Codable {
    
    var authenticated: Bool = false
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
    
    @Published var token: String {
        didSet {
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    
    @Published var id: Int {
        didSet {
            UserDefaults.standard.set(id, forKey: "id")
        }
    }
    
    var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
    
    init() {
        self.token = UserDefaults.standard.string(forKey: "token") ?? ""
        self.id = UserDefaults.standard.integer(forKey: "id")
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
