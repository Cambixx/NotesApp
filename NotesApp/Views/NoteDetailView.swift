import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var showingColorPicker = false
    @State private var showingDeleteAlert = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedTags: [Tag]
    @State private var editedImages: [Note.NoteImage]
    @State private var editedDrawings: [Drawing]
    @State private var showingDrawingCanvas = false
    
    init(note: Note, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedTags = State(initialValue: note.tags)
        _editedImages = State(initialValue: note.images)
        _editedDrawings = State(initialValue: note.drawings)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isEditing {
                    TextField("Título", text: $editedTitle)
                        .font(.title)
                    
                    TextEditor(text: $editedContent)
                        .frame(minHeight: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Section("Imágenes") {
                        ImagePicker(images: $editedImages, content: $editedContent)
                    }
                    
                    TagEditor(tags: $editedTags)
                    
                    Section("Dibujos") {
                        if !editedDrawings.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(editedDrawings) { drawing in
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
                } else {
                    Text(note.title)
                        .font(.title)
                    
                    if !note.images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(note.images) { noteImage in
                                    if let image = noteImage.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                    
                    Text(note.content)
                    
                    if !note.tags.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(tag.color.color.opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if !note.drawings.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(note.drawings) { drawing in
                                    DrawingThumbnail(drawing: drawing)
                                        .frame(width: 200, height: 200)
                                        .onTapGesture {
                                            editedDrawings = note.drawings
                                            isEditing = true
                                            showingDrawingCanvas = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()
        }
        .background(note.color.color)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { viewModel.togglePin(note) }) {
                    Image(systemName: note.isPinned ? "pin.fill" : "pin")
                }
                
                Button(action: { viewModel.toggleFavorite(note) }) {
                    Image(systemName: note.isFavorite ? "star.fill" : "star")
                }
                
                Button(action: { showingColorPicker = true }) {
                    Image(systemName: "paintpalette")
                }
                
                Button(action: {
                    if isEditing {
                        viewModel.updateNote(
                            note,
                            title: editedTitle,
                            content: editedContent,
                            tags: editedTags,
                            images: editedImages,
                            drawings: editedDrawings
                        )
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Guardar" : "Editar")
                }
                
                Menu {
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Eliminar nota", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("¿Eliminar nota?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                viewModel.deleteNote(note)
                dismiss()
            }
        } message: {
            Text("Esta acción no se puede deshacer")
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerView(note: note, viewModel: viewModel)
        }
        .sheet(isPresented: $showingDrawingCanvas) {
            NavigationStack {
                DrawingCanvas(drawings: $editedDrawings)
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

struct TagEditor: View {
    @Binding var tags: [Tag]
    @State private var newTagName = ""
    @State private var showingColorPicker = false
    @State private var newTagColor: Tag.TagColor = .blue
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Etiquetas")
                .font(.headline)
            
            HStack {
                TextField("Nueva etiqueta", text: $newTagName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: { showingColorPicker = true }) {
                    Circle()
                        .fill(newTagColor.color)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.primaryColor)
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
        .sheet(isPresented: $showingColorPicker) {
            TagColorPickerView(selectedColor: $newTagColor)
        }
    }
    
    private func addTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty && !tags.contains(where: { $0.name == name }) {
            let tag = Tag(name: name, color: newTagColor)
            tags.append(tag)
            newTagName = ""
        }
    }
}

struct ColorPickerView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
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
                    ForEach(Note.NoteColor.allCases, id: \.self) { color in
                        VStack {
                            Circle()
                                .fill(color.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if note.color == color {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                        }
                                    }
                                )
                            
                            Text(color.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.updateNoteColor(note, color: color)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Color de la nota")
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