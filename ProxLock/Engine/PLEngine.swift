import Foundation
import CoreBluetooth
import SwiftUI

typealias DBm = Double

class PLEngine: NSObject, ObservableObject {
    private let minimumRssiBeforeUnavailable: DBm = -85.0
    
    private var manager: CBCentralManager!
    
    let range: ClosedRange<DBm> = (-80.0)...(-30.0)
    let dBmStep: Double = 5.0
    
    // Modified both internally and from the UI
    @Published var status: PLEngineStatus
    
    @Published var settings: PLEngineSettings
    
    @Published var monitoredDevice: PLDevice?
    
    @Published var allDevices: [UUID : PLDevice] = [:]
    
    var allDevicesSortedByRSSI: [PLDevice] { allDevices.values.sorted { $0.rssi > $1.rssi } }
    
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
            CBCentralManagerScanOptionAllowDuplicatesKey: true
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
    
    func setMonitoredDevice(uuid: UUID) {
        withAnimation(.bouncy) { monitoredDevice = allDevices[uuid] }
        withAnimation { let _ = allDevices.removeValue(forKey: uuid) }
        self.objectWillChange.send()
    }
    
    func unsetMonitoredDevice() {
        withAnimation(.bouncy) { monitoredDevice = nil }
        self.objectWillChange.send()
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
        
        let uuid = peripheral.identifier
        let rssi = DBm(truncating: RSSI)
        
        // If the peripheral is currently set as monitored, we don't wanna show it in the
        // allDevices, otherwise the user would see it in the Available panel. Hence, we
        // need to filter the UUID of that one. We want to push new RSSI updates though,
        // so that they can be displayed in the Monitor panel.
        if uuid == monitoredDevice?.uuid {
            PLLogger.debug("[SCAN MONITORED] Updating: RSSI=[\()]")
        }
        
        // If the peripheral has RSSI too low, we simply remove it from the available devices
        // dictionary, or if it was never present, we simply ignore it by not adding it.
        // This prevents the user to select devices with a weak signal.
        if rssi < minimumRssiBeforeUnavailable {
            PLLogger.debug("[SCAN] Device \(name) has RSSI below minimum (was \(rssi)): Ignoring it")
            withAnimation { let _ = allDevices.removeValue(forKey: uuid) }
            return
        }
        
        guard let dev = allDevices[uuid] else {
            PLLogger.debug("[SCAN] Adding new device: \(name)")
            withAnimation { allDevices[uuid] = .init(type: deviceType, uuid: uuid, name: name, rssi: rssi) }
            return
        }
        
        let oldRSSI = dev.rssi
        dev.updateData(state: peripheral.state, rssi: DBm(truncating: RSSI))
        self.objectWillChange.send()
        
        PLLogger.debug("[SCAN] Updating device \(name): RSSI=[\(oldRSSI) -> \(dev.rssi)]")
    }
}
