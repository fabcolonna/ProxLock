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
                    PLToggle(isOn: $wakeThresholdToggle, symbol: "wake", text: .init("PLWakeUpThresholdToggle"))
                    .onChange(of: wakeThresholdToggle, perform: { value in
                        withAnimation(.bouncy) {
                            settings.wakeThresholdEnabled = value
                            settings.wakeThreshold = value ? stepperRange.upperBound : .nan
                        }
                    })
                    
                    PLToggle(isOn: $settings.lockToScreenSaver, symbol: "photo", text: .init("PLLockToScreensaverToggle"))
                    PLToggle(isOn: $settings.pauseNowPlaying, symbol: "pause.fill", text: .init("PLPauseNowPlayingToggle"))
                }
                
                Divider()
                
                VStack {
                    PLToggle(isOn: $settings.launchOnLogin, symbol: "app.dashed", text: .init("PLLaunchOnLoginOption"))
                    PLToggle(isOn: $settings.delayBeforeLocking, symbol: "clock", text: .init("PLDelayBeforeLockingOption"))
                    PLToggle(isOn: $settings.noSignalTimeout, symbol: "antenna.radiowaves.left.and.right.slash", text: .init("PLNoSignalTimeoutOption"))
                    PLToggle(isOn: $settings.showRSSIForAnyDevice, symbol: "textformat.123", text: .init("PLShowRSSIForAnyDeviceOption"))
                }
                
                Divider()
                
                VStack {
                    PLStepper(value: $settings.lockThreshold, range: stepperRange,
                              symbol: "sleep", text: .init("PLLockThresholdStepper"), step: dBmStep)
                    
                    if settings.wakeThresholdEnabled {
                        PLStepper(value: $settings.wakeThreshold, range: stepperRange,
                                  symbol: "wake", text: .init("PLWakeUpThresholdStepper"), step: dBmStep)
                    }
                }
            }
        }
    }
}

fileprivate struct PLToggle: View {
    @Binding var isOn: Bool
    
    @State var symbol: String
    @State var text: LocalizedStringKey
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
                .frame(width: 20, height: 20)
            
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
    @State var text: LocalizedStringKey
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
