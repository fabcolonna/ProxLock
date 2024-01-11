import Foundation
import CoreBluetooth

class PLDevice: Identifiable, Hashable {
    let uuid: UUID
    let type: PLDeviceType
    let name: String
    
    var state: CBPeripheralState
    var rssi: DBm
    
    var id: String { uuid.uuidString + String(state.rawValue) + String(rssi) }
    
    init(type: PLDeviceType, uuid: UUID, name: String,
         state: CBPeripheralState = .disconnected, rssi: DBm = .nan) {
    
        self.uuid = uuid
        self.type = type
        self.name = name
        self.state = state
        self.rssi = rssi
    }
    
    func updateData(state: CBPeripheralState, rssi: DBm) {
        self.state = state
        self.rssi = rssi
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // Only checks if UUID are equals, not ID
    static func == (lhs: PLDevice, rhs: PLDevice) -> Bool { lhs.uuid == rhs.uuid }
    
    static let mock: PLDevice = .init(type: .AirPodsPro, uuid: UUID(), name: "AirPods")
}

struct PLDeviceType {
    let symbolName: String
    
    private init(symbolName: String) { self.symbolName = symbolName }
    
    static func fromManufactureData(data: NSData) -> PLDeviceType? {
        // Check if it's an Apple device
        let appleByteSequence: [UInt8] = [0x4C, 0x00]
        
        return data.prefix(2).elementsEqual(appleByteSequence) ? .AirPods3 : nil
    }
    
    fileprivate static let iPhone        = PLDeviceType(symbolName: "iphone")
    fileprivate static let AppleWatch    = PLDeviceType(symbolName: "applewatch.side.right")
    fileprivate static let AirPods       = PLDeviceType(symbolName: "airpods")
    fileprivate static let AirPods3      = PLDeviceType(symbolName: "airpods.gen3")
    fileprivate static let AirPodsPro    = PLDeviceType(symbolName: "airpodspro")
    fileprivate static let AirPodsMax    = PLDeviceType(symbolName: "airpodsmax")
}
