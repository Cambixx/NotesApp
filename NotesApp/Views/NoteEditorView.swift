import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotesViewModel
    @State private var title = ""
    @State private var content = ""
    @State private var tagInput = ""
    @State private var tags: [Tag] = []
    @State private var images: [Note.NoteImage] = []
    @State private var showingColorPicker = false
    @State private var newTagColor: Tag.TagColor = .blue
    @State private var drawings: [Drawing] = []
    @State private var showingDrawingCanvas = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Título", text: $title)
                TextEditor(text: $content)
                    .frame(minHeight: 100)
                
                Section("Imágenes") {
                    ImagePicker(images: $images, content: $content)
                }
                
                Section("Etiquetas") {
                    HStack {
                        TextField("Agregar etiqueta", text: $tagInput)
                        
                        Button(action: { showingColorPicker = true }) {
                            Circle()
                                .fill(newTagColor.color)
                                .frame(width: 24, height: 24)
                        }
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(tags) { tag in
                            HStack {
                                Circle()
                                    .fill(tag.color.color)
                                    .frame(width: 8, height: 8)
                                Text(tag.name)
                                Button(action: { tags.removeAll { $0.id == tag.id } }) {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(tag.color.color.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Section("Dibujos") {
                    if !drawings.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(drawings) { drawing in
                                    DrawingThumbnail(drawing: drawing)
                                        .frame(width: 100, height: 100)
                                        .onTapGesture {
                                            showingDrawingCanvas = true
                                        }
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showingDrawingCanvas = true
                    }) {
                        Label("Añadir dibujo", systemImage: "pencil.tip")
                    }
                }
            }
            .navigationTitle("Nueva Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        viewModel.addNote(
                            title: title,
                            content: content,
                            tags: tags,
                            images: images,
                            drawings: drawings
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                TagColorPickerView(selectedColor: $newTagColor)
            }
            .sheet(isPresented: $showingDrawingCanvas) {
                NavigationStack {
                    DrawingCanvas(drawings: $drawings)
                        .navigationTitle("Dibujo")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cerrar") {
                                    showingDrawingCanvas = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func addTag() {
        let name = tagInput.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty && !tags.contains(where: { $0.name == name }) {
            let tag = Tag(name: name, color: newTagColor)
            tags.append(tag)
            tagInput = ""
        }
    }
} 