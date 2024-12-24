import SwiftUI
import PencilKit

struct DrawingCanvas: View {
    @Binding var drawings: [Drawing]
    @Environment(\.dismiss) var dismiss
    @State private var currentStroke: Drawing.Stroke?
    @State private var selectedColor: Drawing.DrawingColor = .black
    @State private var lineWidth: Float = 2
    @State private var showingColorPicker = false
    @State private var currentDrawing: Drawing
    
    init(drawings: Binding<[Drawing]>) {
        self._drawings = drawings
        if let existingDrawing = drawings.wrappedValue.first {
            _currentDrawing = State(initialValue: existingDrawing)
        } else {
            _currentDrawing = State(initialValue: Drawing(strokes: []))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.white
                
                Canvas { context, size in
                    for stroke in currentDrawing.strokes {
                        var path = Path()
                        if let firstPoint = stroke.points.first {
                            path.move(to: firstPoint)
                            for point in stroke.points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        context.stroke(path, with: .color(stroke.color.color), lineWidth: CGFloat(stroke.lineWidth))
                    }
                    
                    if let stroke = currentStroke {
                        var path = Path()
                        if let firstPoint = stroke.points.first {
                            path.move(to: firstPoint)
                            for point in stroke.points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        context.stroke(path, with: .color(stroke.color.color), lineWidth: CGFloat(stroke.lineWidth))
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            if currentStroke == nil {
                                currentStroke = Drawing.Stroke(
                                    points: [point],
                                    color: selectedColor,
                                    lineWidth: lineWidth
                                )
                            } else {
                                currentStroke?.points.append(point)
                            }
                        }
                        .onEnded { _ in
                            if let stroke = currentStroke {
                                currentDrawing.strokes.append(stroke)
                                currentStroke = nil
                            }
                        }
                )
            }
            
            HStack {
                Picker("Color", selection: $selectedColor) {
                    ForEach(Drawing.DrawingColor.allCases, id: \.self) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 20, height: 20)
                            .tag(color)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
                
                Slider(value: $lineWidth, in: 1...10) {
                    Text("Grosor")
                }
                
                Button(action: {
                    currentDrawing.strokes.removeAll()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    if drawings.isEmpty {
                        drawings.append(currentDrawing)
                    } else {
                        drawings[0] = currentDrawing
                    }
                    dismiss()
                }
            }
        }
    }
} 