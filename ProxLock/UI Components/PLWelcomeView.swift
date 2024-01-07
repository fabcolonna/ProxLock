import SwiftUI

struct PLWelcomeView: View {
    @Binding var mainSwitch: Bool
    
    @State private var internalMainSwitch = false
    @State private var animating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 31, weight: .bold))
                    .shadow(radius: 5)
                
                Text(PLApp.appName)
                    .font(.system(size: 31, weight: .bold))
                    .shadow(radius: 5)
            }
            
            Toggle("", isOn: $internalMainSwitch)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .shadow(radius: 5)
                .onChange(of: internalMainSwitch) { _, newValue in
                    withAnimation {
                        mainSwitch = newValue
                    }
                }
            
            Spacer()
        }
        .opacity(animating ? 1.0 : 0.0)
        .scaleEffect(animating ? 1.0 : 0.5)
        .onAppear {
            withAnimation(.bouncy(duration: 0.5, extraBounce: 0.3)) {
                animating.toggle()
            }
        }
        
        Text("Made with ♥️ by fabcolonna")
            .font(.system(size: 11, weight: .regular))
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
