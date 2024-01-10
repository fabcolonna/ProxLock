import Foundation

struct PLLogger {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    static func debugRich(_ message: String, file: String? = #file,
                    function: String? = #function, line: Int? = #line) {
        let timestamp = PLLogger.dateFormatter.string(from: Date())
        
        guard let file = file, let function = function, let line = line else {
            print("\(timestamp) :: \(message)")
            return
        }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("\(timestamp) @@ [\(fileName):\(line) - \(function)] :: \(message)")
    }
    
    static func debug(_ message: String) { PLLogger.debugRich(message, file: nil, function: nil, line: nil) }
}
