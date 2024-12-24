import SwiftUI

struct Tag: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var color: TagColor
    
    enum TagColor: String, Codable, CaseIterable {
        case blue
        case green
        case red
        case purple
        case orange
        case pink
        case teal
        case indigo
        
        var color: Color {
            switch self {
            case .blue: return Color(.systemBlue)
            case .green: return Color(.systemGreen)
            case .red: return Color(.systemRed)
            case .purple: return Color(.systemPurple)
            case .orange: return Color(.systemOrange)
            case .pink: return Color(.systemPink)
            case .teal: return Color(.systemTeal)
            case .indigo: return Color(.systemIndigo)
            }
        }
        
        var name: String {
            switch self {
            case .blue: return "Azul"
            case .green: return "Verde"
            case .red: return "Rojo"
            case .purple: return "Morado"
            case .orange: return "Naranja"
            case .pink: return "Rosa"
            case .teal: return "Verde azulado"
            case .indigo: return "Índigo"
            }
        }
    }
} 