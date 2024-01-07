struct PLDeviceType {
    let symbol: String
    
    private init(symbol: String) {
        self.symbol = symbol
    }
    
    static let iPhone        = PLDeviceType(symbol: "iphone")
    static let AppleWatch    = PLDeviceType(symbol: "applewatch.side.right")
    static let AirPods       = PLDeviceType(symbol: "airpods")
    static let AirPods3      = PLDeviceType(symbol: "airpods.gen3")
    static let AirPodsPro    = PLDeviceType(symbol: "airpodspro")
    static let AirPodsMax    = PLDeviceType(symbol: "airpodsmax")
}

struct PLDevice: Hashable, Identifiable, Equatable {
    static let defaultDevice: PLDevice = .init(type: .AirPodsPro, name: "AirPods Pro di Fabio", 
                                               UUID: "", macAddress: "")
    
    let type: PLDeviceType
    let name: String
    
    var UUID: String
    var macAddress: String
    var signalStrengthDBm: Double = .nan
    
    var selected = false
    
    // Identifiable
    var id: String { name + "," + macAddress + "," + UUID }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(UUID + macAddress)
    }
    
    static func == (lhs: PLDevice, rhs: PLDevice) -> Bool {
        return lhs.macAddress == rhs.macAddress && lhs.UUID == rhs.UUID
    }
}
