import Foundation

struct PLEngineStatus: Identifiable, Equatable {
    let id = UUID()
    
    let type: PLEngineStatusType
    let message: String?
    
    init(_ type: PLEngineStatusType = .OK, message: String? = nil) {
        self.type = type
        self.message = message
    }
    
    static let OK: PLEngineStatus = .init()
}

enum PLEngineStatusType {
    case OK
    case Error
}
