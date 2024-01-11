import SwiftUI

struct PLMonitorPanel: View {
    @State var device: PLDevice?
    @State var dBmStep: Double
    
    private let chartRange: ClosedRange<DBm> = (-85.0)...(-25.0)
        
    var body: some View {
        if let device = device {
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
                        
                        Text(device.rssi.isNaN ? "" : "\(String(format: "%.0f", device.rssi)) dBm")
                            .font(.system(size: 12, design: .monospaced))
                            .frame(alignment: .trailing)
                            .padding(.trailing)
                    }
                    
                    PLSignalChart(rssiRange: chartRange, step: dBmStep)
                        .frame(height: 25)
                }
            }
        }
    }
}
