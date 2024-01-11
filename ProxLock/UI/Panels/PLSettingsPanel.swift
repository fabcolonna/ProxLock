import SwiftUI
import MacControlCenterUI

struct PLSettingsPanel: View {
    @Binding var settings: PLEngineSettings
    
    @State var stepperRange: ClosedRange<DBm>
    @State var dBmStep: Double
    
    @State private var expanded = false
    @State private var wakeThresholdToggle = false
    
    @ViewBuilder private var header: some View {
        HStack {
            Text("PLConfigPanel")
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button { withAnimation(.bouncy) { expanded.toggle() } } label: {
                Image(systemName: expanded ? "chevron.down" : "chevron.up")
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.bouncy) { expanded.toggle() } }
    }
    
    var body: some View {
        MenuPanel {
            header
            
            if expanded {
                VStack {
                    PLToggle(isOn: $wakeThresholdToggle, symbol: "wake", text: "PLWakeUpThresholdToggle")
                    .onChange(of: wakeThresholdToggle, perform: { value in
                        withAnimation(.bouncy) {
                            settings.wakeThresholdEnabled = value
                            settings.wakeThreshold = value ? stepperRange.upperBound : .nan
                        }
                    })
                    
                    PLToggle(isOn: $settings.lockToScreenSaver, symbol: "photo", text: "PLLockToScreensaverToggle")
                    PLToggle(isOn: $settings.pauseNowPlaying, symbol: "pause.fill", text: "PLPauseNowPlayingToggle")
                }
                
                Divider()
                
                VStack {
                    PLToggle(isOn: $settings.launchOnLogin, symbol: "app.dashed", text: "PLLaunchOnLoginOption")
                    PLToggle(isOn: $settings.delayBeforeLocking, symbol: "clock", text: "PLDelayBeforeLockingOption")
                    PLToggle(isOn: $settings.noSignalTimeout, symbol: "wifi.slash", text: "PLNoSignalTimeoutOption")
                }
                
                Divider()
                
                VStack {
                    PLStepper(value: $settings.lockThreshold, range: stepperRange,
                                 symbol: "sleep", text: "PLLockThresholdStepper", step: dBmStep)
                    
                    if settings.wakeThresholdEnabled {
                        PLStepper(value: $settings.wakeThreshold, range: stepperRange,
                                     symbol: "wake", text: "PLWakeUpThresholdStepper", step: dBmStep)
                    }
                }
            }
        }
    }
}

fileprivate struct PLToggle: View {
    @Binding var isOn: Bool
    
    @State var symbol: String
    @State var text: String
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
            Text(text)
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        .padding(2)
    }
}

fileprivate struct PLStepper: View {
    @Binding var value: DBm

    @State var range: ClosedRange<DBm>
    @State var symbol: String
    @State var text: String
    @State var step: Double
    
    @State private var animate = false
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
            Text(text)
            Spacer()
            
            Stepper(value: $value, in: range, step: step) {
                Text("\(String(format: "%.0f", value)) dBm")
                    .font(.system(size: 12, design: .monospaced))
            }
        }
        .opacity(animate ? 1.0 : 0.0)
        .onAppear { withAnimation(.bouncy) { animate.toggle() } }
    }
}
