import Foundation
import SwiftUI

struct PLSignalChart: View {
    @EnvironmentObject var engine: PLEngine
    
    @State var range: ClosedRange<PLEngine.DBm>
    @State var showThresholds: Bool
    @State var step: Double
    
    @State private var leds: Int
    
    init(range: ClosedRange<PLEngine.DBm>, showThresholds: Bool, step: Double) {
        self.range = range
        self.showThresholds = showThresholds
        self.step = step
        
        leds = Int(abs(range.upperBound - range.lowerBound) / step + 1)
    }
    
    var body: some View {
        HStack {
            ForEach(0..<leds, id: \.self) { i in
                Led(taller: checkIfThreshold(index: i))
            }
        }
        .padding(.trailing)
    }
    
    private func checkIfThreshold(index: Int) -> Bool {
        if !showThresholds {
            return false
        }
        
        let amount = range.lowerBound + (Double(index) * engine.thresholdStep)
        return amount == engine.lockThreshold || amount == engine.wakeThreshold
    }
}
     
fileprivate struct Led: View {
    var taller: Bool
    
    var body: some View {
        Rectangle()
            .fill(.green)
            .frame(height: taller ? 25 : 18)
            .cornerRadius(4)
    }
}
 
