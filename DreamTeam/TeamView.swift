//
//  TeamView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 3/2/21.
//

import SwiftUI

struct TeamView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: TeamMemberView()) {
                    Image(systemName: "person")
                        .frame(width: 30)
                    Text("Todd")
                }
                Text("Add team member")
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarTitle("Family", displayMode: .inline)
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView()
    }
}
