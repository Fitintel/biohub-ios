//
//  BIOHUBApp.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-03.
//

import SwiftUI
import Observation
import FirebaseCore
import FirebaseAppCheck

// Overarching app state
@Observable
class AppState<B: PBiodyn, BD: PeripheralsDiscovery<B>>
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    var selectedTab: Tab = .home
    var home = HomeRouter()
    var net = NetRouter()
    var fitnet: Fitnet<B, BD>
    var fitnetUser: FitnetUser?
    var isLoggedIn: Bool { get { fitnetUser != nil } }
    
    init(deviceDiscovery: BD) {
        let pm = Fitnet(deviceDiscovery)
        self.fitnet = pm
    }
}

// Main page app tabs
enum Tab { case home, net }

// UI routes within tabs
@Observable
final class HomeRouter { var path: [HomeViewRoute] = [] }
enum HomeViewRoute: Hashable { case home, signIn }
@Observable
final class NetRouter { var path: [NetViewRoute] = [] }
enum NetViewRoute: Hashable { case create, configure, selfTest, dataCollection, imu, emg, net3d }

@main
struct BIOHUBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var app = AppState(deviceDiscovery: BluetoothPeripheralsDiscovery.shared)
//    @State private var app = AppState(deviceDiscovery: TestPeripheralsDiscovery())
    
    var body: some Scene {
        WindowGroup {
            MainView(app: app)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // TODO: register with App Check instead of using debug token
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        FirebaseApp.configure()
        return true
    }
}

