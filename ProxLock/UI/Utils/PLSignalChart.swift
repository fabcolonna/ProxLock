import Foundation
import SwiftUI

struct PLSignalChart: View {
    @EnvironmentObject var engine: PLEngine
    
    @Binding var rssi: DBm
    
    @State var rssiRange: ClosedRange<DBm>
    @State var step: Double
    
    @State private var leds: Int
    
    init(rssiRange: ClosedRange<DBm>, step: Double, rssi: Binding<DBm> = .constant(.nan)) {
        self._rssi = rssi
        self.rssiRange = rssiRange
        self.step = step
        
        leds = Int(abs(rssiRange.upperBound - rssiRange.lowerBound) / step + 1)
    }
    
    var body: some View {
        HStack {
            ForEach(0..<leds, id: \.self) { i in
                Rectangle()
                    .fill(i <= mapRSSIToIndex() ? .green : .white.opacity(0.2))
                    //.frame(height: taller ? 25 : 18)
                    .cornerRadius(4)
            }
        }
        //.padding(.trailing)
    }
    
    private func mapRSSIToIndex() -> Int {
        if rssi.isNaN { return -1 }
        
        let normalizedRSSI = (rssi - rssiRange.lowerBound) / (rssiRange.upperBound - rssiRange.lowerBound)
        return Int(round(normalizedRSSI * Double(leds - 1)))
    }
}
 
