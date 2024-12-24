import Foundation
import SwiftUI

struct Note: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var tags: [Tag]
    var images: [NoteImage]
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var color: NoteColor
    var isFavorite: Bool
    var drawings: [Drawing]
    
    enum NoteColor: String, Codable, CaseIterable {
        case default_
        case red
        case orange
        case yellow
        case green
        case blue
        case purple
        case pink
        case teal
        case indigo
        case brown
        case mint
        
        var color: Color {
            @Environment(\.colorScheme) var colorScheme
            
            let opacity = colorScheme == .dark ? 0.3 : 0.15
            
            switch self {
            case .default_: return .clear
            case .red: return Color(.systemRed).opacity(opacity)
            case .orange: return Color(.systemOrange).opacity(opacity)
            case .yellow: return Color(.systemYellow).opacity(opacity)
            case .green: return Color(.systemGreen).opacity(opacity)
            case .blue: return Color(.systemBlue).opacity(opacity)
            case .purple: return Color(.systemPurple).opacity(opacity)
            case .pink: return Color(.systemPink).opacity(opacity)
            case .teal: return Color(.systemTeal).opacity(opacity)
            case .indigo: return Color(.systemIndigo).opacity(opacity)
            case .brown: return Color(.systemBrown).opacity(opacity)
            case .mint: return Color(.systemMint).opacity(opacity)
            }
        }
        
        var name: String {
            switch self {
            case .default_: return "Por defecto"
            case .red: return "Rojo"
            case .orange: return "Naranja"
            case .yellow: return "Amarillo"
            case .green: return "Verde"
            case .blue: return "Azul"
            case .purple: return "Morado"
            case .pink: return "Rosa"
            case .teal: return "Verde azulado"
            case .indigo: return "Índigo"
            case .brown: return "Marrón"
            case .mint: return "Menta"
            }
        }
    }
    
    struct NoteImage: Identifiable, Codable {
        var id: UUID = UUID()
        var imageData: Data
        
        var image: UIImage? {
            UIImage(data: imageData)
        }
    }
} 