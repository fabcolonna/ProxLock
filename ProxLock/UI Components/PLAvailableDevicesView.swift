import Foundation
import SwiftUI
import MacControlCenterUI

fileprivate struct PLDeviceEntry: View {
    @State var device: PLDevice
    
    @State private var isHovered: Bool = false
    
    private let chartRange: ClosedRange<PLEngine.DBm> = (-90.0)...(-25.0)
    private let step = 15.0
    
    var body: some View {
        ZStack {
            Color(white: 0.1, opacity: 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .opacity(isHovered ? 0.2 : 0.0)
            
            HStack {
                Image(systemName: device.type.symbol)
                    .font(.system(size: 24.0))
                
                Text(device.name)
                Spacer()
                
                PLSignalChart(range: chartRange,
                              showThresholds: false, step: step)
                .frame(width: 70)
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

struct PLAvailableDevicesView: View {
    @EnvironmentObject var engine: PLEngine
    
    @State var expanded = false
    
    @State private var selectedDevice: PLDevice.ID?
    
    var body: some View {
        MenuPanel {
            HStack {
                Text("PLFallbackDev")
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !engine.allDevices.isEmpty {
                    ProgressView()
                }
                
                Spacer()
                
                Button(action: {
                    if engine.status == .OK {
                        withAnimation(.bouncy) { expanded.toggle() }
                    }
                }) {
                    Image(systemName: expanded ? "chevron.down" : "chevron.up")
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .gesture(TapGesture(count: 1).onEnded {
                if engine.status == .OK {
                    withAnimation(.bouncy) { expanded.toggle() }
                }
            })
            
            if expanded {
                ZStack {
                    if engine.allDevices.isEmpty {
                        VStack {
                            ProgressView()
                                .scaleEffect(0.5)
                        }
                        .padding(8)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(engine.allDevices, id: \.id) { device in
                                    PLDeviceEntry(device: device)
                                }
                            }
                        }
                    }
                }
                .onAppear { engine.startScan() }
                .onDisappear { engine.stopScan() }
            }
        }
        .opacity(engine.status == .OK ? 1.0 : 0.5)
        //.frame(height: expanded ? 175 : 35)
    }
}
