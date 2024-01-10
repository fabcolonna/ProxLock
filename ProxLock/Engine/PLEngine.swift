import Foundation
import CoreBluetooth
import OrderedCollections

typealias DBm = Double

class PLEngine: NSObject, ObservableObject {
    private var manager: CBCentralManager!
    
    let range: ClosedRange<DBm> = (-80.0)...(-30.0)
    let dBmStep: Double = 5.0
    
    // Modified both internally and from the UI
    @Published var status: PLEngineStatus
    
    @Published var settings: PLEngineSettings
    
    @Published var monitoredDevice: PLDevice?
    
    @Published var allDevices: OrderedDictionary<UUID, PLDevice> = [:]
    
    var allDevicesSortedByRSSI: Array<(key: UUID, value: PLDevice)> {
        allDevices.elements.sorted(by: { $0.value.rssi > $1.value.rssi })
    }
    
    var isScanning: Bool { manager.isScanning }
    
    override init() {
        status = .OK
        settings = PLEngineSettings(lockThreshold: range.lowerBound, wakeThreshold: .nan)
        
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        guard !manager.isScanning else { return }
        
        // We must error until status is OK in order to be sure that everything is OK
        if status.type != .OK {
            PLLogger.debug("Got start scan request. Refused: Status is not OK")
            return
        }
        
        PLLogger.debug("Got start scan request. OK")
        manager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }
    
    func stopScan() {
        guard manager.isScanning else {
            PLLogger.debug("Got stop scan request. Refused: Central was not scanning")
            return
        }
        
        PLLogger.debug("Got stop scan request. OK")
        manager.stopScan()
        allDevices.removeAll()
    }
}

extension PLEngine: CBCentralManagerDelegate {
    // Callback -> CBCM calls it when state is updated
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.status = .OK
            PLLogger.debug("Central status update: OK")
        case .poweredOff:
            self.status = PLEngineStatus(.Error, message: "Make sure that Bluetooth is on!")
            PLLogger.debug("Central status update: BT OFF")
        default:
            self.status = PLEngineStatus(.Error, message: "A fatal error occurred 😪")
            PLLogger.debug("Central status update: FATAL")
        }
    }
    
    // Callback -> CBCM calls it whenever a new peripheral becomes available during scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // Filtering found devices -> only show devices which have a name, and are connectable
        guard let name = peripheral.name,
              let _ = advertisementData[CBAdvertisementDataIsConnectable] as? Bool
        else { return }
        
        // Only Apple devices are supported. Info about manufacturer and model need to be
        // extracted from the following object. If device is Apple and it's supported by this
        // app, deviceType variable won't be nil
        guard let info = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData,
              let deviceType: PLDeviceType = .fromManufactureData(data: info)
        else { return }
        
        let device: PLDevice = .init(type: deviceType, id: peripheral.identifier, name: name,
                                     rssi: DBm(truncating: RSSI))
        
        allDevices.updateValue(device, forKey: peripheral.identifier)
    }
}
