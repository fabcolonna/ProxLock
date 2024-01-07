import SwiftUI
import MacControlCenterUI

struct PLView: View {
    @EnvironmentObject var engine: PLEngine

    @State private var mainSwitch = false
    @State private var gradientAnimOnAppear = false

    var body: some View {
        ZStack {
            if false {
                LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .opacity(mainSwitch ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: mainSwitch)
                    .opacity(gradientAnimOnAppear ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            gradientAnimOnAppear.toggle()
                        }
                    }
            }
             
            
            VStack(spacing: 10) {
                if mainSwitch {
                    PLMainSwitchView(mainSwitch: $mainSwitch)
                        .transition(.opacity)
                    
                    PLStatusView()
                        .transition(.opacity)
                    
                    PLAvailableDevicesView()
                    
                    PLSettingsView()
                } else { PLWelcomeView(mainSwitch: $mainSwitch) }
            }
            .padding()
        }
        .frame(width: 350)
    }
}

#Preview {
    PLView()
        .environmentObject(PLEngine())
        .frame(height: 700)
}

