import SwiftUI

struct PLHeaderPanel: View {
    @EnvironmentObject var engine: PLEngine
    
    @Binding var mainSwitch: Bool
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Toggle("", isOn: $mainSwitch)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .shadow(radius: 5)
                        .onChange(of: mainSwitch, perform: { new in
                            withAnimation { mainSwitch = new }
                        })
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .bold))
                        .shadow(radius: 5)
                    
                    Text(PLApp.appName)
                        .font(.system(size: 15, weight: .bold))
                        .shadow(radius: 5)
                }
                
                Spacer()
                
                HStack {
                    if let _ = engine.monitoredDevice {
                        Button { engine.unsetMonitoredDevice() } label: {
                            Text("Stop using")
                        }
                    }
                    
                    Button { NSApplication.shared.terminate(nil) } label: {
                        Image(systemName: "power.circle.fill")
                            .font(.system(size: 20.0, weight: .regular))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .shadow(radius: 5)
                }
            }
        }
    }
}
