import SwiftUI

@main
struct PLApp: App {
    static let appName = "ProxLock"

    @StateObject var engine = PLEngine()
    
    var body: some Scene {
        MenuBarExtra(PLApp.appName, systemImage: "lock.fill") {
            PLView()
                .fixedSize()
                .environmentObject(engine)
                .background(.ultraThinMaterial)
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentMinSize)
    }
}
