import Foundation

enum PLStatusType {
    case OK
    case Error
}

struct PLStatus: Identifiable, Hashable, Equatable {
    let id = UUID()
    
    let type: PLStatusType
    let message: String?
    
    init(_ type: PLStatusType = .OK, message: String? = nil) {
        self.type = type
        self.message = message
    }
    
    static let OK = PLStatus()
}
