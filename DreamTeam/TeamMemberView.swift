//
//  TeamMemberView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 3/2/21.
//

import SwiftUI

struct TeamMemberView: View {
    
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $userName)
                }
                
                Section(header: Text("Email")) {
                    TextField("Email", text: $userEmail)
                }
                
                Button("Remove") {
                    //
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarTitle("Todd", displayMode: .inline)
    }
}

struct TeamMemberView_Previews: PreviewProvider {
    static var previews: some View {
        TeamMemberView()
    }
}
