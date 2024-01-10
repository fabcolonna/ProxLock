import SwiftUI
import MacControlCenterUI

struct PLSettingsView: View {
    @EnvironmentObject var engine: PLEngine
    
    @State private var expanded = false
    @State private var internalWakeThresholdEnabled = false
    
    var body: some View {
        MenuPanel {
            header
            
            if expanded {
                circleToggles
                Divider()
                toggles
                Divider()
                
                VStack {
                    PLDBmStepper(stepperValue: $engine.settings.lockThreshold,
                                 stepperRange: engine.range,
                                 symbol: "sleep", text: "PLLockThresholdStepper", step: engine.dBmStep)
                    
                    if engine.settings.wakeThresholdEnabled {
                        PLDBmStepper(stepperValue: $engine.settings.wakeThreshold,
                                     stepperRange: engine.range,
                                     symbol: "wake", text: "PLWakeUpThresholdStepper", step: engine.dBmStep)
                    }
                }
                .onChange(of: [engine.settings.lockThreshold, engine.settings.wakeThreshold]) {
                    engine.status = engine.settings.lockThreshold >= engine.settings.wakeThreshold
                    ? PLEngineStatus(.Error, message: "PLInvalidThresholdStatusError")
                    : .OK
                }
            }
        }
        .frame(height: expanded ? nil : 35)
    }
    
    @ViewBuilder private var header: some View {
        HStack {
            Text("PLConfigPanel")
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: { withAnimation(.bouncy) { expanded.toggle() } }) {
                Image(systemName: expanded ? "chevron.down" : "chevron.up")
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .gesture(TapGesture(count: 1).onEnded {
            withAnimation(.bouncy) { expanded.toggle() }
        })
    }
    
    @ViewBuilder private var circleToggles: some View {
        HStack {
            PLCircleToggle(isOn: $internalWakeThresholdEnabled,
                           symbol: "wake",
                           text: "PLWakeUpThresholdToggle",
                           textFrameWidth: 55.0)
            .onChange(of: internalWakeThresholdEnabled) { _, newValue in
                withAnimation(.bouncy) {
                    engine.settings.wakeThresholdEnabled = newValue
                    engine.settings.wakeThreshold = newValue ? engine.range.upperBound : .nan
                }
            }
            
            PLCircleToggle(isOn: $engine.settings.lockToScreenSaver,
                           symbol: "photo",
                           text: "PLLockToScreensaverToggle",
                           textFrameWidth: 80.0)
            
            PLCircleToggle(isOn: $engine.settings.pauseNowPlaying,
                           symbol: "pause.fill",
                           text: "PLPauseNowPlayingToggle",
                           textFrameWidth: 70.0)
        }
        .frame(height: 80)
    }
    
    @ViewBuilder private var toggles: some View {
        PLToggle(isOn: $engine.settings.launchOnLogin, symbol: "app.dashed",
                 text: "PLLaunchOnLoginOption")
        
        PLToggle(isOn: $engine.settings.delayBeforeLocking, symbol: "clock",
                 text: "PLDelayBeforeLockingOption")
        
        PLToggle(isOn: $engine.settings.noSignalTimeout, symbol: "wifi.slash",
                 text: "PLNoSignalTimeoutOption")
    }
}

fileprivate struct PLCircleToggle: View {
    @Binding var isOn: Bool
    
    @State var symbol: String
    @State var text: String
    @State var textFrameWidth: CGFloat
    
    var body: some View {
        MenuCircleToggle(isOn: $isOn, controlSize: .prominent,
                         style: .init(image: Image(systemName: symbol),
                                      color: .accentColor,
                                      invertForeground: true)) {
            Text(text)
                .font(.system(size: 11))
                .multilineTextAlignment(.center)
                .frame(width: textFrameWidth)
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

fileprivate struct PLDBmStepper: View {
    @Binding var stepperValue: DBm

    @State var stepperRange: ClosedRange<DBm>
    @State var symbol: String
    @State var text: String
    @State var step: Double
    
    @State private var animate = false
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
            Text(text)
            Spacer()
            
            Stepper(value: $stepperValue, in: stepperRange, step: step) {
                Text("\(String(format: "%.0f", stepperValue)) dBm")
                    .font(.system(size: 12, design: .monospaced))
            }
        }
        .opacity(animate ? 1.0 : 0.0)
        .onAppear { withAnimation(.bouncy) { animate.toggle() } }
    }
}
