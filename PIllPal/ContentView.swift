//
//  ContentView.swift
//  PIllPal
//
//  Created by mathis goffin on 29/04/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            HomeView().tabItem {
                Image(systemName: "house")
                Text("home")
            }
            
            HerrineringView().tabItem {
                Image(systemName: "bell")
                Text("herinnering")
            }
            KalenderView().tabItem {
                Image(systemName: "calendar")
                Text("kalender")
            }
            
        }
    }
}







#Preview {
    ContentView()
}
