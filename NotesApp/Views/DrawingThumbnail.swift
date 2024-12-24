import SwiftUI

struct DrawingThumbnail: View {
    let drawing: Drawing
    
    var body: some View {
        Canvas { context, size in
            // Prevenir división por cero si no hay puntos
            guard !drawing.strokes.isEmpty else { return }
            
            // Calcular el bounds de todos los trazos
            var minX: CGFloat = .infinity
            var minY: CGFloat = .infinity
            var maxX: CGFloat = -.infinity
            var maxY: CGFloat = -.infinity
            
            for stroke in drawing.strokes {
                for point in stroke.points {
                    minX = min(minX, point.x)
                    minY = min(minY, point.y)
                    maxX = max(maxX, point.x)
                    maxY = max(maxY, point.y)
                }
            }
            
            // Si no encontramos puntos válidos, salir
            guard minX != .infinity else { return }
            
            // Calcular la escala y el offset para centrar el dibujo
            let drawingWidth = maxX - minX
            let drawingHeight = maxY - minY
            
            // Prevenir división por cero
            guard drawingWidth > 0, drawingHeight > 0 else { return }
            
            let scale = min(
                size.width / drawingWidth,
                size.height / drawingHeight
            ) * 0.9 // 90% del tamaño para dejar un margen
            
            let offsetX = (size.width - drawingWidth * scale) / 2 - minX * scale
            let offsetY = (size.height - drawingHeight * scale) / 2 - minY * scale
            
            // Dibujar los trazos escalados y centrados
            for stroke in drawing.strokes {
                var path = Path()
                if let firstPoint = stroke.points.first {
                    let scaledPoint = CGPoint(
                        x: firstPoint.x * scale + offsetX,
                        y: firstPoint.y * scale + offsetY
                    )
                    path.move(to: scaledPoint)
                    
                    for point in stroke.points.dropFirst() {
                        let scaledPoint = CGPoint(
                            x: point.x * scale + offsetX,
                            y: point.y * scale + offsetY
                        )
                        path.addLine(to: scaledPoint)
                    }
                }
                context.stroke(
                    path,
                    with: .color(stroke.color.color),
                    lineWidth: max(1, CGFloat(stroke.lineWidth) * scale)
                )
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
} 