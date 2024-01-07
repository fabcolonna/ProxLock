import Foundation
import CoreBluetooth

fileprivate class Logger {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    static func log(_ message: String, file: String = #file, 
                    function: String = #function, line: Int = #line) {

        let timestamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "\(timestamp) [\(fileName):\(line) - \(function)] \(message)"

        print(logMessage)
    }
}

class PLEngine: NSObject, CBCentralManagerDelegate, ObservableObject {
    typealias DBm = Double
    
    private var manager: CBCentralManager!
    
    let range: ClosedRange<DBm> = (-80.0)...(-30.0)
    
    let thresholdStep: Double = 5.0
    
    @Published var selectedDevice: PLDevice?
    
    @Published var allDevices: [PLDevice] = []
    
    @Published var status: PLStatus
    
    @Published var settings = PLSettings()
    
    @Published var lockThreshold: DBm
    @Published var wakeThreshold: DBm = .nan
    
    override init() {
        status = .OK
        
        lockThreshold = range.lowerBound
        
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
        
        Logger.log("Starting PLEngine")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Changes to published vars must be done from the same thread
        // in order to trigger UI re-rendering
        switch central.state {
        case .poweredOn:
            self.status = .OK
            Logger.log("CBCM state is OK. Bluetooth is working. Scanning peripherals can begin.")
            
        case .poweredOff:
            self.status = PLStatus(.Error, message: PLApp.appName + " needs Bluetooth to work!")
            Logger.log("Bluetooth may be off.")
            
        case .unauthorized:
            self.status = PLStatus(.Error,
                                   message: PLApp.appName + " requires Bluetooth authorization to work!")
            Logger.log("User did not authenticate.")
            
        default:
            self.status = PLStatus(.Error,
                                   message: "A fatal error occurred 😪 Please try restarting the app!")
            Logger.log("CBCM is broken.")
        }
    }
    
    func startScan() {
        if status.type != .OK {
            Logger.log("Requested scan. Cannot proceed because status is not OK.")
            return
        }
        
        Logger.log("Requested scan. Proceeding.")
        
        // withServices should be populated. I need to do that.
        manager.scanForPeripherals(withServices: nil)
        
    }
    
    func stopScan() {
        if manager.isScanning {
            Logger.log("Requested stop scan. Proceeding.")
            
            manager.stopScan()
            allDevices.removeAll()
        }
        
        Logger.log("Requested stop scan. Nothing to stop.")
    }
    
    // Called every time manager discovers a new peripheral, provided that the scan
    // is in progress.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Logger.log("Found Device: \(peripheral.name)")
        
    }
}
