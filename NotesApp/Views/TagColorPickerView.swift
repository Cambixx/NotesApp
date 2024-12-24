import SwiftUI

struct TagColorPickerView: View {
    @Binding var selectedColor: Tag.TagColor
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Tag.TagColor.allCases, id: \.self) { tagColor in
                        VStack {
                            Circle()
                                .fill(tagColor.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if selectedColor == tagColor {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                        }
                                    }
                                )
                            
                            Text(tagColor.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedColor = tagColor
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Color de etiqueta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
} 