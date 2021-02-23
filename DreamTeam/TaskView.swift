//
//  TaskView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 1/8/21.
//

import SwiftUI

struct TaskView: View {
    
    //@ObservedObject var deviceUser = DeviceUser()
    @ObservedObject var userSettings = UserSettings()
    
    let task: Task
    let width: CGFloat = 100
    @State var isButtonLeft: Bool = false
    @State var isButtonRight: Bool = false
    @State var isHaptic: Bool = true
    @State var isLoading: Bool = false
    @State var offset = CGSize.zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack (alignment: .leading) {
                
                // Lower layer
                HStack {
                    HStack {
                        if self.isLoading == true {
                            ProgressView()
                        } else {
                            Button(actionText()) {
                                self.actionTask(action: actionType())
                            }
                        }
                    }
                    .frame(width: width, height: geo.size.height)
                    .background(Color.red)
                    .foregroundColor(.white)
                    
                    // Only show right button if task active
                    if isActive() {
                        Spacer()
                        HStack {
                            if self.isLoading == true {
                                ProgressView()
                            } else {
                                Button("Complete") {
                                    self.actionTask(action: "complete")
                                }
                            }
                        }
                        .frame(width: width, height: geo.size.height)
                        .background(Color.green)
                        .foregroundColor(.white)
                    }
                }
                
                // Upper layer
                HStack {
                    Text(task.title)
                        .padding()
                        .fixedSize() // so that longer titles are not truncated - has to be before frame()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                        .background(isActive() ? Color(.systemGray5) : Color.white)
                        .foregroundColor(
                            (task.completed == nil) ?
                                ((task.skipped == nil) ?
                                    (!isOverdue() ?
                                        Color.black : Color.red)
                                : Color.red)
                            : Color.secondary.opacity(0.5)
                        )
                }
                .offset(self.offset)
                .animation(.spring())
                .gesture(DragGesture()
                    .onChanged { gesture in
                        if isActive() == true || // If task is active (ie. not completed, deleted or skipped)
                            (isActive() == false && gesture.translation.width > 0) || // If not active, only allow left btn
                            (isActive() == false && self.offset.width > 0) // If not active, but left btn showing, return to center
                        {
                            // Only send haptic after gesture gets half way and if starting from middle
                            if isHaptic == true &&
                                isButtonLeft == false && // Only if buttons not showing
                                isButtonRight == false && // Only if buttons not showing
                                (gesture.translation.width > 50 || gesture.translation.width < -50) // Only after trigger
                            {
                                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                impactHeavy.impactOccurred()
                                isHaptic = false // Set false so we only get a single haptic (reset after button shows)
                            }

                            if gesture.translation.width < 100 && gesture.translation.width > -100 {
                                self.offset.width = gesture.translation.width
                            }

                        }
                    }
                    .onEnded { _ in
                        if self.offset.width < -0.5 * width && isActive() && self.isButtonLeft == false {
                            // Right button
                            self.offset.width = -width
                            self.isButtonLeft = false
                            self.isButtonRight = true
                            self.isHaptic = true

                        } else if self.offset.width > 0.5 * width && self.isButtonRight == false {
                            // Left button
                            self.offset.width = width
                            self.isButtonLeft = true
                            self.isButtonRight = false
                            self.isHaptic = true
                        } else {
                            // Back to center
                            self.offset.width = .zero
                            self.isButtonLeft = false
                            self.isButtonRight = false
                            self.isHaptic = true
                        }
                    }
                )
            }
        }
    }
    
    func actionTask(action: String) {
        let url = URL(string: "http://34.208.204.33:8080/tasks/" + "\(task.id)" + "/" + action + "?user_id=" + "\(userSettings.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Start spinner
        self.isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: Notification.Name("FeedRefresh"), object: nil)
                
                // Reset task, hide buttons
                // self.offset.width = .zero
                
                // End spinner
                self.isLoading = false
            }
        }
        .resume()
    }
    
    func actionText() -> String {
        if task.type == "habit" && task.completed == nil && task.skipped == nil {
            return "Skip"
        } else if task.type == "task" && task.completed == nil && task.skipped == nil {
            return "Delete"
        } else {
            return "Undo"
        }
    }
    
    func actionType() -> String {
        if task.type == "habit" && task.completed == nil && task.skipped == nil {
            return "skip"
        } else if task.type == "task" && task.completed == nil && task.skipped == nil {
            return "delete"
        } else if task.skipped != nil {
            return "unskip"
        } else if task.deleted != nil {
            return "undelete"
        }
        return "uncomplete"
    }
    
    func isActive() -> Bool {
        if task.completed == nil && task.deleted == nil && task.skipped == nil {
            return true
        }
        return false
    }
    
    func isOverdue() -> Bool {
        let formatter = ISO8601DateFormatter()
        let now = Date()
        if now > formatter.date(from: task.due)! {
            return true
        }
        return false
    }
}

//struct TaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskView(task: Task())
//    }
//}
