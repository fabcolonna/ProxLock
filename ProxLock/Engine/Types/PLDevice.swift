import Foundation
import CoreBluetooth

class PLDevice: Identifiable, Equatable {
    let id: UUID
    let type: PLDeviceType
    let name: String
    
    var state: CBPeripheralState
    var rssi: DBm
    
    init(type: PLDeviceType, id: UUID, name: String,
         state: CBPeripheralState = .disconnected, rssi: DBm = .nan) {
    
        self.id = id
        self.type = type
        self.name = name
        self.state = state
        self.rssi = rssi
    }

    static func == (lhs: PLDevice, rhs: PLDevice) -> Bool { lhs.id == rhs.id }
    
    static let mock: PLDevice = .init(type: .AirPodsPro, id: UUID(), name: "AirPods")
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
