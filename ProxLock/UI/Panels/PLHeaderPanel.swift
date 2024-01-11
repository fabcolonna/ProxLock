import SwiftUI

struct PLHeaderPanel: View {
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
                
                Button { NSApplication.shared.terminate(nil) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20.0, weight: .regular))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .shadow(radius: 5)
            }
        }
    }
}
