import SwiftUI

struct Drawing: Identifiable, Codable {
    var id: UUID = UUID()
    var strokes: [Stroke]
    
    struct Stroke: Identifiable, Codable {
        var id: UUID = UUID()
        var points: [CGPoint]
        var color: DrawingColor
        var lineWidth: Float
        
        enum CodingKeys: String, CodingKey {
            case id, color, lineWidth, points
        }
        
        init(id: UUID = UUID(), points: [CGPoint], color: DrawingColor, lineWidth: Float) {
            self.id = id
            self.points = points
            self.color = color
            self.lineWidth = lineWidth
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            color = try container.decode(DrawingColor.self, forKey: .color)
            lineWidth = try container.decode(Float.self, forKey: .lineWidth)
            
            let pointStrings = try container.decode([String].self, forKey: .points)
            points = pointStrings.compactMap { pointString in
                let components = pointString.split(separator: ",").compactMap { Double($0) }
                guard components.count == 2 else { return nil }
                return CGPoint(x: components[0], y: components[1])
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(color, forKey: .color)
            try container.encode(lineWidth, forKey: .lineWidth)
            
            let pointStrings = points.map { "\($0.x),\($0.y)" }
            try container.encode(pointStrings, forKey: .points)
        }
    }
    
    enum DrawingColor: String, Codable, CaseIterable {
        case black, blue, red, green
        
        var color: Color {
            switch self {
            case .black: return .black
            case .blue: return .blue
            case .red: return .red
            case .green: return .green
            }
        }
    }
} 