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
    
    @State var authService = AuthService()
    @Bindable var app: AppState<B, BD>
    
    var body: some View {
        Group {
            TabView(selection: $app.selectedTab) {
                NavigationStack(path: $app.home.path) {
                    HomeView(app: app)
                        .navigationTitle("BIOHUB Home")
                        .navigationDestination(for: HomeViewRoute.self) { route in
                            switch route {
                            case .home: HomeView(app: app)
                            case .signIn: AuthView(app: app)
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
                            case .dataCollection: DataCollectionNetView(app: app, dNet: DataCollectionNetMode(app.fitnet))
                            case .imu: IMUNetView(app: app, imuNet: IMUNetMode(app.fitnet))
                            case .emg: EMGNetView(app: app, emgNet: EMGNetMode(app.fitnet))
                            case .net3d: Net3DView(app: app, net: Net3DMode(app.fitnet))
                            }
                        }
                }
                .tabItem { Label("Create Net", systemImage: "antenna.radiowaves.left.and.right") }
                .tag(Tab.net)
                .onChange(of: app.fitnet.biodyns.isEmpty) { wasEmpty, isEmpty in
                    if isEmpty && !wasEmpty {
                        app.net.path.removeAll()
                    }
                }
            }
        }
        .environmentObject(authService)
    }
}


