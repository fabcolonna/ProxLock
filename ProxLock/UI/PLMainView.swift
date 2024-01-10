import SwiftUI
import MacControlCenterUI

struct PLMainView: View {
    @EnvironmentObject var engine: PLEngine
    
    @Binding var mainSwitch: Bool
    
    @State private var errored = false

    var body: some View {
        VStack(spacing: 10) {
            PLHeaderPanel(mainSwitch: $mainSwitch)
                .transition(.opacity)
            
            MenuPanel {
                ZStack {
                    PLMonitorPanel(device: .mock, dBmStep: engine.dBmStep)
                        .transition(.opacity)
                        .blur(radius: errored ? 10.0 : 0.0)
                        .opacity(errored ? 0.5 : 1.0)
                    
                    if let err = engine.status.message {
                        PLErrorPanel(error: err)
                            .transition(.opacity)
                            .opacity(errored ? 1.0 : 0.0)
                            .onAppear { withAnimation(.bouncy) { errored.toggle() } }
                            .onDisappear { withAnimation(.bouncy) { errored = false } }
                    }
                }
            }
            .frame(height: errored ? nil : 80)
            
            PLDevicesPanel(errored: $errored)
            
            PLSettingsView()
        }
    }
}
