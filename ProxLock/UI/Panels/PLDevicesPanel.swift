import Foundation
import SwiftUI
import MacControlCenterUI

struct PLDevicesPanel: View {
    @EnvironmentObject var engine: PLEngine
    
    @Binding var errored: Bool
    
    @State private var expanded = false

    @ViewBuilder private var header: some View {
        HStack {
            Text("PLFallbackDev")
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if engine.isScanning {
                ProgressView()
                    .controlSize(.small)
                    .opacity(expanded ? 1.0 : 0.0)
            }
            
            Spacer()
            
            Button {
                if !errored {  withAnimation(.bouncy) { expanded.toggle() } }
            } label: { Image(systemName: expanded ? "chevron.down" : "chevron.up") }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture { if !errored { withAnimation(.bouncy) { expanded.toggle() } } }
    }
    
    var body: some View {
        MenuPanel {
            header
            
            if !errored, expanded {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(engine.allDevicesSortedByRSSI, id: \.id) { dev in
                            PLDeviceEntry(device: dev)
                                .transition(.opacity)
                        }
                    }
                }
                .frame(height: engine.allDevicesSortedByRSSI.count > 0 ? nil : 0)
                .onAppear { engine.startScan() }
                .onDisappear { engine.stopScan() }
            }
        }
        .opacity(!errored ? 1.0 : 0.5)
    }
}

fileprivate struct PLDeviceEntry: View {
    @State var device: PLDevice
    
    @State private var isHovered: Bool = false
    
    private let chartRange: ClosedRange<DBm> = (-80.0)...(-35.0)
    private let step = 15.0
    
    var body: some View {
        ZStack {
            Color(white: 0.1, opacity: 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .opacity(isHovered ? 0.2 : 0.0)
            
            HStack {
                Image(systemName: device.type.symbolName)
                    .font(.system(size: 24.0))
                
                Text(device.name)
                Spacer()
                
                Text(device.rssi.isNaN ? "" : "\(String(format: "%.0f", device.rssi))")
                    .font(.system(size: 12, design: .monospaced))
                
                PLSignalChart(rssiRange: chartRange, step: step, rssi: $device.rssi)
                    .frame(width: 70, height: 18)
                    .padding(.trailing)
            }
            .padding(4)
            .buttonStyle(.plain)
            .overlay (
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(white: 0.1, opacity: 0.5), lineWidth: 0.5)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(white: 0.4), lineWidth: 0.5)
                        .padding(0.5)
                }
                .opacity(isHovered ? 0.5 : 0.2)
            )
            .onHover(perform: { hovering in
                withAnimation { isHovered = hovering }
            })
        }
    }
}
