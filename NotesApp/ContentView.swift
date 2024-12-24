//
//  ContentView.swift
//  NotesApp
//
//  Created by Carlos Rábago on 20/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    @State private var showingTagFilter = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    SearchBar(text: $viewModel.searchText)
                        .padding()
                    
                    if !viewModel.allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.allTags) { tag in
                                    TagButton(
                                        tag: tag,
                                        isSelected: viewModel.selectedTags.contains(tag)
                                    ) {
                                        if viewModel.selectedTags.contains(tag) {
                                            viewModel.selectedTags.remove(tag)
                                        } else {
                                            viewModel.selectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.filteredNotes) { note in
                                NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                                    NoteCard(note: note, viewModel: viewModel)
                                }
                                .contextMenu {
                                    Button(action: {
                                        viewModel.togglePin(note)
                                    }) {
                                        Label(
                                            note.isPinned ? "Desfijar" : "Fijar",
                                            systemImage: note.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                    
                                    Button(action: {
                                        viewModel.toggleFavorite(note)
                                    }) {
                                        Label(
                                            note.isFavorite ? "Quitar de favoritos" : "Añadir a favoritos",
                                            systemImage: note.isFavorite ? "star.slash" : "star"
                                        )
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        viewModel.deleteNote(note)
                                    }) {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Notas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                NoteEditorView(viewModel: viewModel)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            
            TextField("Buscar notas...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(8)
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
}

struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(tag.color.color)
                    .frame(width: 8, height: 8)
                Text(tag.name)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        isSelected ? 
                        AppTheme.primaryColor : 
                        (colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemGray6))
                    )
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    .cornerRadius(20)
            }
        }
    }
}

struct NoteCard: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    if !note.images.isEmpty {
                        Image(systemName: "photo")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text(note.content)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(AppTheme.textSecondary)
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(note.tags) { tag in
                            HStack {
                                Circle()
                                    .fill(tag.color.color)
                                    .frame(width: 8, height: 8)
                                Text(tag.name)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(tag.color.color.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            HStack {
                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(note.color.color.opacity(colorScheme == .dark ? 0.2 : 0.15))
        .cardStyle()
    }
}

#Preview {
    ContentView()
}
