//
//  TaskView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 1/8/21.
//

import SwiftUI

struct TaskView: View {
    
    // @ObservedObject var deviceUser = DeviceUser()
    @ObservedObject var userSettings = UserSettings()
    
    let task: Task
    
    // Upper level - Task
    @GestureState private var offset: CGFloat = 0 // Cannot be updated, so we need offsetAuto below
    @State var offsetAuto: CGFloat = 0 // Used to automate full slide away on action
    
    // Lower level - Actions - Left Side
    @State var leftHaptic: Bool = false // To ensure a single haptic feedback
    @State var leftTriggerOffset: CGFloat = 100 // The offset width when action is triggered
    @State var leftWidth: CGFloat = 0 // To control width of action to mimic Gmail app
    
    // Lower level - Actions - Right Side
    @State var rightHaptic: Bool = false // To ensure a single haptic feedback
    @State var rightTriggerOffset: CGFloat = -100 // The offset width when action is triggered
    @State var rightWidth: CGFloat = 0 // To control width of action to mimic Gmail app
    
    var body: some View {
        GeometryReader { geo in
            ZStack (alignment: .leading) {
                
                // Lower layer - Actions
                HStack(spacing: 0) { // Spacing = 0 so action width calculation is correct
                    if leftWidth > 0 { // To avoid glitch on portrain/landscape switch
                        HStack {
                            Text(Image(systemName: "xmark.circle.fill"))
                                .opacity(offset + offsetAuto > leftTriggerOffset ? 1 : 0.25)
                            Text(actionText())
                                .opacity(offset + offsetAuto > leftTriggerOffset ? 1 : 0.25)
                        }
                        .padding()
                        .frame(width: leftWidth, height: geo.size.height, alignment: .leading)
                        .background(isActive() && isOverdue() ? Color.black : Color.red)
                        .foregroundColor(.white)
                    }
                    
                    if rightWidth > 0 { // To avoid glitch on portrain/landscape switch
                        HStack {
                            Text("Done")
                                .opacity(offset + offsetAuto < rightTriggerOffset ? 1 : 0.25)
                            Text(Image(systemName: "checkmark.circle.fill"))
                                .opacity(offset + offsetAuto < rightTriggerOffset ? 1 : 0.25)
                        }
                        .padding()
                        .frame(width: rightWidth, height: geo.size.height, alignment: .trailing)
                        .background(Color.green)
                        .foregroundColor(.white)
                    }
                }
                
                // Upper layer - Task
                HStack {
                    Text(task.title)
                        .padding()
                        .fixedSize() // so that longer titles are not truncated - has to be before frame()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                        .background(!isActive() ? Color(.systemBackground) : isMessage() ? Color.yellow : isOverdue() ? Color.red : Color(.systemGray5))
                        .foregroundColor(!isActive() ? Color(.systemGray5) : isOverdue() ? Color.white : Color(.label))
                }
                .offset(x: offset + offsetAuto) // Offset is ummutable, so we need offset for automated slide away
                .animation(.spring())
                .gesture(DragGesture()
                    .updating($offset) { (value, gestureState, transaction) in
                        // Using this with @GestureState to return to 0 even if interrupted by scrolling
                        // State cannot be mutated in .updating, so we only control movement here
                        
                        let delta = value.location.x - value.startLocation.x
                        
                        // Left button - except for messages
                        if delta > 0 && delta < geo.size.width/2 && !isMessage() { // Upper limit for UX
                            gestureState = delta
                        }

                        // Right button - except for inactive
                        if delta < 0 && delta > -geo.size.width/2 && isActive() { // Upper limit for UX
                            gestureState = delta
                        }
                    }
                    .onChanged { gesture in
                        // Using this to update @State variables, which we cannot do in .updating
                        // In here we control dynaic action width and haptic feedback
                        let width = gesture.translation.width
                        
                        // Left button
                        if offset > 0 {
                            // This helps with smooth switching between left and right
                            leftWidth = min(geo.size.width/2 + offset, geo.size.width)
                            rightWidth = max(geo.size.width/2 - offset, 0)
                            
                            // Haptic if passes left trigger
                            if !leftHaptic && width > leftTriggerOffset {
                                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                impactHeavy.impactOccurred()
                                leftHaptic = true
                                rightHaptic = false
                            }
                            
                            // Haptic cancel
                            if leftHaptic && width < leftTriggerOffset {
                                leftHaptic = false
                            }
                        }

                        // Right button
                        if offset < 0 {
                            // This helps with smooth switching between left and right
                            leftWidth = max(geo.size.width/2 + offset/2, 0)
                            rightWidth = min(geo.size.width/2 - offset/2, geo.size.width)
                            
                            // Haptic if passes right trigger
                            if !rightHaptic && width < rightTriggerOffset {
                                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                impactHeavy.impactOccurred()
                                leftHaptic = false
                                rightHaptic = true
                            }
                            
                            // Haptic cancel
                            if rightHaptic && width > rightTriggerOffset {
                                rightHaptic = false
                            }
                        }
                    }
                    .onEnded { value in
                        // Using this to trigger actions when gesture is finished (finger raised)
                        // Once action starts, we automate the task to slide away out of view
                        
                        let delta = value.location.x - value.startLocation.x
                        
                        // Left button
                        if delta > leftTriggerOffset && !isMessage() { // Must add !isMessage to work correctly
                            leftWidth = geo.size.width
                            rightWidth = 0
                            
                            // API call
                            self.actionTask(action: actionType())
                            
                            // Animate slide all the way
                            for index in Int(delta)...Int(geo.size.width) {
                                offsetAuto = CGFloat(index)
                            }
                        }
                        
                        // Right button
                        if delta < rightTriggerOffset && isActive() { // Must add isActive to work correctly
                            leftWidth = 0
                            rightWidth = geo.size.width
                            
                            // API call
                            self.actionTask(action: "complete")
                            
                            // Animate slide all the way
                            for index in (0...Int(geo.size.width - delta)) {
                                offsetAuto = CGFloat(-index)
                            }
                        }
                        
                        // Reset haptics
                        leftHaptic = false
                        rightHaptic = false
                    }
                )
            }
        }
    }
    
    func actionTask(action: String) {
        let url = URL(string: "http://34.208.204.33:8080/tasks/" + "\(task.id)" + "/" + action + "?token=" + "\(userSettings.token)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: Notification.Name("FeedRefresh"), object: nil)
            }
        }
        .resume()
    }
    
    func actionText() -> String {
        if isActive() {
            if task.type == "habit" {
                return "Skip"
            } else {
                return "Delete"
            }
        } else {
            return "Undo"
        }
    }
    
    func actionType() -> String {
        if isActive() {
            if task.type == "habit" {
                return "skip"
            } else {
                return "delete"
            }
        } else {
            if task.skipped != nil {
                return "unskip"
            } else if task.deleted != nil {
                return "undelete"
            } else {
                return "uncomplete"
            }
        }
    }
    
    func isActive() -> Bool {
        return task.completed == nil && task.deleted == nil && task.skipped == nil ? true : false
    }
    
    func isMessage() -> Bool {
        return task.type == "message" ? true : false
    }
    
    func isOverdue() -> Bool {
        let formatter = ISO8601DateFormatter()
        let now = Date()
        return now > formatter.date(from: task.due)! ? true : false
    }
}

//struct TaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskView(task: Task())
//    }
//}
