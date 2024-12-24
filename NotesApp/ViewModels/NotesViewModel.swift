import Foundation

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText = ""
    @Published var selectedTags: Set<Tag> = []
    private let saveKey = "savedNotes"
    
    var filteredNotes: [Note] {
        var filtered = notes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        if !selectedTags.isEmpty {
            filtered = filtered.filter { note in
                !Set(note.tags).isDisjoint(with: selectedTags)
            }
        }
        
        return filtered.sorted { note1, note2 in
            if note1.isPinned != note2.isPinned {
                return note1.isPinned
            }
            return note1.updatedAt > note2.updatedAt
        }
    }
    
    var allTags: [Tag] {
        Array(Set(notes.flatMap { $0.tags })).sorted { $0.name < $1.name }
    }
    
    init() {
        loadNotes()
    }
    
    func addNote(title: String, content: String, tags: [Tag], images: [Note.NoteImage], drawings: [Drawing]) {
        let note = Note(
            id: UUID(),
            title: title,
            content: content,
            tags: tags,
            images: images,
            createdAt: Date(),
            updatedAt: Date(),
            isPinned: false,
            color: .default_,
            isFavorite: false,
            drawings: drawings
        )
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note, title: String, content: String, tags: [Tag], images: [Note.NoteImage], drawings: [Drawing]) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updatedNote = note
        updatedNote.title = title
        updatedNote.content = content
        updatedNote.tags = tags
        updatedNote.images = images
        updatedNote.drawings = drawings
        updatedNote.updatedAt = Date()
        notes[index] = updatedNote
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
    
    func togglePin(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updatedNote = note
        updatedNote.isPinned.toggle()
        notes[index] = updatedNote
        saveNotes()
    }
    
    func toggleFavorite(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updatedNote = note
        updatedNote.isFavorite.toggle()
        notes[index] = updatedNote
        saveNotes()
    }
    
    func updateNoteColor(_ note: Note, color: Note.NoteColor) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updatedNote = note
        updatedNote.color = color
        notes[index] = updatedNote
        saveNotes()
    }
} 