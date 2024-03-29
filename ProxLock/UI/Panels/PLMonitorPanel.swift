import SwiftUI

struct PLMonitorPanel: View {
    @EnvironmentObject var engine: PLEngine
    
    @State var dBmStep: Double
    
    @State private var showRSSI = false
    
    private let chartRange: ClosedRange<DBm> = (-85.0)...(-25.0)
        
    var body: some View {
        if let device = engine.monitoredDevice {
            HStack {
                Image(systemName: device.type.symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                
                VStack (alignment: .leading) {
                    HStack {
                        Text(device.name)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if showRSSI {
                            Text(device.rssi.isNaN ? "" : "\(String(format: "%.0f", device.rssi)) dBm")
                                .font(.system(size: 12, design: .monospaced))
                                .frame(alignment: .trailing)
                                .padding(.trailing)
                                .opacity(showRSSI ? 1.0 : 0.0)
                                .scaleEffect(showRSSI ? 1.0 : 0.5)
                        }
                    }
                    
                    PLSignalChart(rssiRange: chartRange, step: dBmStep, 
                                  rssi: Binding(get: { device.rssi }, set: { val in device.rssi = val }))
                        .frame(height: 25)
                }
            }
            .onAppear { showRSSI = engine.settings.showRSSIForAnyDevice }
            .onChange(of: engine.settings.showRSSIForAnyDevice, perform: { value in
                withAnimation(.easeInOut) { showRSSI = value }
            })
        }
    }
}
