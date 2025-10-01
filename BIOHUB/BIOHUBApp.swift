//
//  BIOHUBApp.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-03.
//

import SwiftUI
import Observation

@Observable
class AppState<B: PBiodyn, BD: PeripheralsDiscovery<B>>
    where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    var selectedTab: Tab = .home
    var home = HomeRouter()
    var net = NetRouter()
    var fitnet: Fitnet<B, BD>
    var isLoggedIn: Bool = false
    
    init(deviceDiscovery: BD) {
        let pm = Fitnet(deviceDiscovery)
        self.fitnet = pm
    }
}

enum Tab { case home, net }
@Observable
final class HomeRouter { var path: [HomeViewRoute] = [] }
@Observable
final class NetRouter { var path: [NetViewRoute] = [] }

enum HomeViewRoute: Hashable { case home, signIn }
enum NetViewRoute: Hashable { case create, configure, selfTest, dataCollection }

@main
struct BIOHUBApp: App {
    
//  @State private var app = AppState(deviceDiscovery: BluetoothPeripheralsDiscovery.shared)
    @State private var app = AppState(deviceDiscovery: TestPeripheralsDiscovery())

    var body: some Scene {
        WindowGroup {
            MainView(app: app)
        }
    }
}
