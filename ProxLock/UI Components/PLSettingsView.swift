import SwiftUI
import MacControlCenterUI

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
    @Binding var stepperValue: PLEngine.DBm

    @State var stepperRange: ClosedRange<PLEngine.DBm>
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

struct PLSettingsView: View {
    @EnvironmentObject var engine: PLEngine
    
    @State private var expanded = false
    @State private var internalWakeThresholdEnabled = false
    
    var body: some View {
        MenuPanel {
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
            
            if expanded {
                HStack {
                    PLCircleToggle(isOn: $internalWakeThresholdEnabled,
                                   symbol: "wake",
                                   text: "Wake Up Threshold",
                                   textFrameWidth: 55.0)
                    .onChange(of: internalWakeThresholdEnabled) { _, status in
                        withAnimation(.bouncy) {
                            engine.settings.wakeThresholdEnabled = status
                            engine.wakeThreshold = status ? engine.range.upperBound : .nan
                        }
                    }
                    
                    PLCircleToggle(isOn: $engine.settings.lockToScreenSaver,
                                   symbol: "photo",
                                   text: "Lock to Screensaver",
                                   textFrameWidth: 80.0)
                    
                    PLCircleToggle(isOn: $engine.settings.pauseNowPlaying,
                                   symbol: "pause.fill",
                                   text: "Pause Now Playing",
                                   textFrameWidth: 70.0)
                }
                .frame(height: 80)
                
                Divider()
                
                PLToggle(isOn: $engine.settings.launchOnLogin, symbol: "app.dashed",
                         text: "Launch on Login")
                
                PLToggle(isOn: $engine.settings.delayBeforeLocking, symbol: "clock",
                         text: "Delay before Locking")
                
                PLToggle(isOn: $engine.settings.noSignalTimeout, symbol: "wifi.slash",
                         text: "No Signal Timeout")
                
                Divider()
                
                VStack {
                    PLDBmStepper(stepperValue: $engine.lockThreshold,
                                 stepperRange: engine.range,
                                 symbol: "sleep", text: "Lock Threshold", step: engine.thresholdStep)
                    
                    if engine.settings.wakeThresholdEnabled {
                        PLDBmStepper(stepperValue: $engine.wakeThreshold,
                                     stepperRange: engine.range,
                                     symbol: "wake", text: "Wake Up Threshold", step: engine.thresholdStep)
                    }
                }
                .onChange(of: [engine.lockThreshold, engine.wakeThreshold]) { _, _ in
                    engine.status = engine.lockThreshold >= engine.wakeThreshold
                    ? PLStatus(.Error,
                               message: "Wake threshold should be greater than Lock threshold")
                    : .OK
                }
            }
        }
        .frame(height: expanded ? nil : 35)
    }
}
