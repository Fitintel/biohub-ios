//
//  ContentView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-03.
//

import SwiftUI
import CoreBluetooth
import OSLog

let log = Logger()


struct MainView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    
    var body: some View {
        Group {
            TabView(selection: $app.selectedTab) {
                NavigationStack(path: $app.home.path) {
                    HomeView()
                        .navigationTitle("BIOHUB Home")
                        .navigationDestination(for: HomeViewRoute.self) { route in
                            switch route {
                            case .home: HomeView()
                            }
                        }
                }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)
                
                NavigationStack(path: $app.net.path) {
                    CreateNetView(app: app)
                        .navigationTitle("Create Net")
                        .navigationDestination(for: NetViewRoute.self) { route in
                            switch route {
                            case .configure: ConfigureNetView(app: app)
                            case .create: CreateNetView(app: app)
                            case .selfTest: SelfTestNetView(app: app, netMode: SelfTestNetMode(app.fitnet))
                            }
                        }
                }
                .tabItem { Label("Create Net", systemImage: "antenna.radiowaves.left.and.right") }
                .tag(Tab.net)
            }
        }
    }
}


