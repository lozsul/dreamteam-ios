//
//  ToolbarView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 2/4/21.
//

import SwiftUI

struct ToolbarView: View {

    @State var isSettings: Bool = false
    @State var isAdd: Bool = false
    
    var body: some View {
        HStack {
                
            Button(action: {
                self.isSettings = true
            }, label: {
            
            Image(systemName: "person")
                .font(.system(.headline))
                .frame(width: 40, height: 35)
                .padding()
                .sheet(isPresented: $isSettings, content: {
                    SettingsView()
                })
            })
            
            VStack {
                Image(systemName: "text.justify")
                    .font(.system(.headline))
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.gray)
                    .padding()
            }
            .background(Color.white)
            .cornerRadius(35)
            .padding()
            
            Button(action: {
                self.isAdd = true
            }, label: {
            
            Image(systemName: "plus")
                .font(.system(.headline))
                .frame(width: 40, height: 35)
                .padding()
                .sheet(isPresented: $isAdd, content: {
                    AddView()
                })
            })
        }
        .frame(height: 50)
        .padding(.top, 5)
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView()
    }
}
