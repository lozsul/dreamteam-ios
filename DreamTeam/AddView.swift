//
//  AddView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 1/18/21.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

struct AddView: View {
    
    @ObservedObject var userSettings = UserSettings()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    var isValid: Bool {
        if title.isEmpty {
            return false
        }
        return true
    }
    
    var frequency: [String] = ["Once", "Recurring"]
    @State private var defaultFrequency = 0
    
    //Dictionary within an array so that the order is kept for display
    @State private var scheduleDays = [
        ScheduleDay(day: "Mo", selected: true),
        ScheduleDay(day: "Tu", selected: true),
        ScheduleDay(day: "We", selected: true),
        ScheduleDay(day: "Th", selected: true),
        ScheduleDay(day: "Fr", selected: true),
        ScheduleDay(day: "Sa", selected: true),
        ScheduleDay(day: "Su", selected: true),
    ]
    
    @State private var teams = [Team]()
    @State private var defaultTeam: Int?
    
    @State private var members = [User]()
    @State private var defaultMember: Int = 0
    
    let assign: [String] = ["Me", "Other", "Anyone", "Everyone"]
    @State private var defaultAssign = 0
    
    @State private var isAny = false
    @State private var isAll = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM dd"
        formatter.timeStyle = .short
        return formatter
    }
    
    let components = Calendar.current.dateComponents([.month, .day], from: Date())
    
    @State private var displayDate = Date()
    @State private var dueDate = Date().addingTimeInterval(3600)
    
    @State private var displayTimes = [
        Timing(id: 0, text: "Now"),
        Timing(id: 1, text: "1 Hour"),
        Timing(id: 24, text: "Tomorrow"),
        Timing(id: 100, text: "Other")]
    @State private var displayTime = 0
    
    @State private var dueTimes = [
        Timing(id: 1, text: "1 Hour"),
        Timing(id: 3, text: "3 Hours"),
        Timing(id: 24, text: "Tomorrow"),
        Timing(id: 100, text: "Other")]
    @State private var dueTime = 1
    
    @State private var habitDisplayTimes = [
        Timing(id: 8, text: "8am"),
        Timing(id: 12, text: "12pm"),
        Timing(id: 16, text: "4pm"),
        Timing(id: 100, text: "Other")]
    @State private var habitDisplayHour = 8
    @State private var habitDisplayOther = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    
    @State private var habitDueTimes = [
        Timing(id: 1, text: "1 Hour"),
        Timing(id: 3, text: "3 Hours"),
        Timing(id: 5, text: "5 Hours"),
        Timing(id: 100, text: "Other")]
    @State private var habitDueHour = 1
    @State private var habitDueOther = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $title)
                        .keyboardType(.default)
                }
                
                Section(header: Text("Frequency")) {
                    Picker("How Often?", selection: $defaultFrequency) {
                        ForEach(0 ..< frequency.count) {
                            Text("\(self.frequency[$0])")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if defaultFrequency == 1 {
                    Section(header: Text("Schedule")) {
                        HStack(spacing: 2) {
                            ForEach(0 ..< scheduleDays.count) { value in
                                Text(scheduleDays[value].day).onTapGesture {
                                    scheduleDays[value].selected = !scheduleDays[value].selected
                                }
                                    .font(.footnote)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(scheduleDays[value].selected ? Color.green : Color.gray))
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Section(header: Text("Team")) {
                    Picker("What Team?", selection: $defaultTeam) {
                        ForEach(teams) { team in
                            Text(team.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if defaultTeam != nil {
                    Section(header: Text("Assign")) {
                        Picker("Who to Assign?", selection: $defaultAssign.onChange(assignChange)) {
                            ForEach(0 ..< assign.count) {
                                Text("\(self.assign[$0])")
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if defaultAssign == 1 {
                            Picker("Who?", selection: $defaultMember) {
                                ForEach(members) { member in
                                    Text(member.username)
                                }
                            }
                            .onAppear(perform: loadMembers)
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                
                // One off Task
                if defaultFrequency == 0 {
                    Section(header: Text("Display")) {
                        Picker("Display Time", selection: $displayTime.onChange(displayCalc)) {
                            ForEach(displayTimes) { time in
                                Text(time.text)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if displayTime == 100 {
                            DatePicker("", selection: $displayDate.onChange(displayDueSync))
                                .datePickerStyle(DefaultDatePickerStyle())
                        }
                    }
                    
                    Section(header: Text("Due In")) {
                        Picker("Due Time", selection: $dueTime.onChange(dueCalc)) {
                            ForEach(dueTimes) { time in
                                Text(time.text)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if dueTime == 100 {
                            DatePicker("", selection: $dueDate)
                                .datePickerStyle(DefaultDatePickerStyle())
                        }
                    }
                    
                // Recurring Habit
                } else {
                    Section(header: Text("Display")) {
                        Picker("Display Time", selection: $habitDisplayHour) {
                            ForEach(habitDisplayTimes) { time in
                                Text(time.text)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if habitDisplayHour == 100 { // how to add (!= 8 or 12 or 16)? so Other doesn't close
                            Picker("", selection: $habitDisplayHour.onChange(updateHabitDisplayOther)) {
                                ForEach(habitDisplayOther, id: \.self) {
                                    if $0 == 0 {
                                        Text("12am")
                                    } else if $0 == 12 {
                                        Text("12pm")
                                    } else if $0 < 12 {
                                        Text("\($0)am")
                                    } else {
                                        Text("\($0-12)pm")
                                    }
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    
                    Section(header: Text("Due After")) {
                        Picker("Due Time", selection: $habitDueHour) {
                            ForEach(habitDueTimes) { time in
                                Text(time.text)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if habitDueHour == 100 {
                            Picker("", selection: $habitDueHour.onChange(updateHabitDueOther)) {
                                ForEach(habitDueOther, id: \.self) {
                                    if $0 == 0 {
                                        Text("On Display")
                                    } else if $0 == 1 {
                                        Text("1 hour")
                                    } else {
                                        Text("\($0) hours")
                                    }
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                }
                
                Button("Save") {
                    if defaultFrequency == 0 {
                        saveNewTask()
                    } else {
                        saveNewHabit()
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Add")
            .navigationBarHidden(true)
        }
        .onAppear(perform: loadTeams)
    }
    
    func displayCalc(h: Int) {
        if h != 100 {
            displayDate = Date().addingTimeInterval(3600 * Double(h))
        } else {
            displayDate = Date()
            dueTime = 100
        }
        displayDueSync(d: displayDate)
    }
    
    func displayDueSync(d: Date) {
        dueDate = d.addingTimeInterval(3600)
    }
    
    func dueCalc(h: Int) {
        if h != 100 {
            dueDate = Date().addingTimeInterval(3600 * Double(h))
        } else {
            dueDate = Date().addingTimeInterval(3600)
        }
    }
    
    func updateHabitDisplayOther(_: Int) {
        
        var habitDisplay = ""
        
        if habitDisplayHour == 0 {
            habitDisplay = "12am"
        } else if habitDisplayHour == 12 {
            habitDisplay = "12pm"
        } else if habitDisplayHour < 12 {
            habitDisplay = "\(habitDisplayHour)am"
        } else {
            habitDisplay = "\(habitDisplayHour-12)pm"
        }
        
        habitDisplayTimes = [
            Timing(id: 8, text: "8am"),
            Timing(id: 12, text: "12pm"),
            Timing(id: 16, text: "4pm"),
            Timing(id: habitDisplayHour, text: "\(habitDisplay)")]
    }
    
    func updateHabitDueOther(_: Int) {
        
        var habitDue = ""
        
        if habitDueHour == 0 {
            habitDue = "On Display"
        } else if habitDueHour == 1 {
            habitDue = "1 Hour"
        } else {
            habitDue = "\(habitDueHour) Hours"
        }
        
        habitDueTimes = [
            Timing(id: 1, text: "1 Hour"),
            Timing(id: 3, text: "3 Hours"),
            Timing(id: 5, text: "5 Hours"),
            Timing(id: habitDueHour, text: "\(habitDue)")]
    }
    
    func assignChange(_: Int) {
        if defaultAssign == 2 {
            isAny = true
            isAll = false
        } else if defaultAssign == 3 {
            isAny = false
            isAll = true
        } else {
            isAny = false
            isAll = false
        }
    }
    
    func loadTeams() {
        
        guard let url = URL(string: "http://34.208.204.33:8080/teams?user_id=" + "\(userSettings.id)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                  let response = try JSONDecoder().decode(TeamsResponse.self, from: data)
                  DispatchQueue.main.async {
                    self.teams = response.teams
                    
                    // Select default team
                    if self.teams.count > 0 {
                        self.defaultTeam = self.teams[0].id!
                    }
                    
                    // Add private
                    let privateTeam = Team(id: nil, title: "Private")
                    self.teams.append(privateTeam)
                   }
                } catch let jsonError as NSError {
                  print("\(jsonError.localizedDescription)")
                }
                return
            }
            self.presentationMode.wrappedValue.dismiss()
        }
        .resume()
    }
    
    func loadMembers() {

        guard let url = URL(string: "http://34.208.204.33:8080/teams/" + "\(defaultTeam!)" + "/members?user_id=" + "\(userSettings.id)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                  let response = try JSONDecoder().decode(MembersResponse.self, from: data)
                  DispatchQueue.main.async {
                    self.members = response.users
                    if self.members.count == 1 {
                        self.defaultMember = self.members[0].id
                    }
                   }
                } catch let jsonError as NSError {
                  print("\(jsonError.localizedDescription)")
                }
                return
            }
        }
        .resume()
    }
    
    // New func to combine saveNewTask() and saveNewHabit()
    func saveNew() {
        
        // If frequency = Once = Task
        if defaultFrequency == 0 {
            
        } else {
            
        }
    }
    
    func saveNewTask() {
        let url = URL(string: "http://34.208.204.33:8080/tasks")!
        var request = URLRequest(url: url)
        
        let formatter = ISO8601DateFormatter()

        let parameters: [String: Any] = [
            "team_id": (defaultTeam == nil ? NSNull() : Int(defaultTeam!)),
            "user_id_created": userSettings.id,
            "user_id_assigned" : (isAny == true || isAll == true ? NSNull() : defaultAssign == 1 ? defaultMember : userSettings.id),
            "title": title,
            "details" : NSNull(),
            "display": formatter.string(from: displayDate),
            "due" : formatter.string(from: dueDate),
            "is_team_any" : isAny,
            "is_team_all" : isAll
        ]
        print(parameters)
        
        request.httpMethod = "POST"
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                    print(json)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("FeedRefresh"), object: nil)
                    }
                } catch {
                    print(error)
                }
            }
        }
        .resume()
    }
    
    func saveNewHabit() {
        let url = URL(string: "http://34.208.204.33:8080/habits")!
        var request = URLRequest(url: url)
        
        let formatterHour = DateFormatter()
        formatterHour.dateFormat = "HH"
        
        let formatterMinute = DateFormatter()
        formatterMinute.dateFormat = "mm"

        var scheduleDaysSelected: [String] = []
        for i in 0..<scheduleDays.count {
            if scheduleDays[i].selected == true {
                scheduleDaysSelected.append(scheduleDays[i].day)
            }
        }
        
        let schedule = scheduleDaysSelected.joined(separator: ",")

        let parameters: [String: Any] = [
            "team_id": (defaultTeam == nil ? NSNull() : Int(defaultTeam!)),
            "user_id_created": userSettings.id,
            "user_id_assigned" : (isAny == true || isAll == true ? NSNull() : defaultAssign == 1 ? defaultMember : userSettings.id),
            "title": title,
            "details" : NSNull(),
            "display_hour": habitDisplayHour,
            "display_minute": 0,
            "due_hour": habitDisplayHour + habitDueHour,
            "due_minute": 0,
            "schedule_days_of_week": schedule.lowercased(),
            "is_team_any" : isAny,
            "is_team_all" : isAll
        ]
        print(parameters)
        
        request.httpMethod = "POST"
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                    print(json)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("FeedRefresh"), object: nil)
                    }
                } catch {
                    print(error)
                }
            }
        }
        .resume()
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
