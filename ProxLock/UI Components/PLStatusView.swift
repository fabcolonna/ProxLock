import SwiftUI
import MacControlCenterUI

struct PLStatusView: View {
    @EnvironmentObject var engine: PLEngine
    
    @State private var device: PLDevice = .defaultDevice
        
    @State private var errorDetected: Bool = false
    @State private var topViewBlur    = 0.0
    @State private var topViewOpacity = 1.0
    
    private let chartRange: ClosedRange<PLEngine.DBm> = (-85.0)...(-25.0)
    
    var body: some View {
        MenuPanel {
            VStack {
                HStack {
                    if errorDetected {
                        Text("PLConfigError")
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        if engine.selectedDevice != nil {
                            Text("PLPrimaryDev")
                                .font(.system(size: 13, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("PLNotConfigured")
                                .font(.system(size: 13, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer()
                    
                    if !errorDetected, !device.signalStrengthDBm.isNaN {
                        Text("\(String(format: "%.0f", device.signalStrengthDBm)) dBm")
                            .font(.system(size: 12, design: .monospaced))
                    }
                }
                
                ZStack {
                    HStack {
                        Image(systemName: device.type.symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                        
                        VStack {
                            Text(device.name)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            
                            PLSignalChart(range: chartRange,
                                          showThresholds: true, step: engine.thresholdStep)
                        }
                    }
                    .blur(radius: errorDetected || engine.selectedDevice == nil ? 10.0 : 0.0)
                    .opacity(errorDetected ? 0.5 : 1.0)
                    .scaleEffect(errorDetected ? 0.8 : 1.0)
                    
                    if engine.status.type == .Error, let message = engine.status.message {
                        HStack {
                            Text(message)
                                .font(.system(size: 13.0, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                        .onAppear { withAnimation(.bouncy) { errorDetected = true } }
                        .onDisappear { errorDetected = false }
                    }
                }
            }
            .onAppear {
                // If a device has actually been selected, it's shown,
                // otherwise a mock device is displayed, but it's blurred out
                guard let dev = engine.selectedDevice else {
                    self.device = PLDevice.defaultDevice
                    return
                }
                
                self.device = dev
            }
        }
        //.frame(height: errorDetected ? 100 : 80)
    }
}
