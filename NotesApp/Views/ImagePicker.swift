import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var images: [Note.NoteImage]
    @Binding var content: String
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isProcessingOCR = false
    @State private var showingOCRAlert = false
    @State private var showingErrorAlert = false
    @State private var ocrResult: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            if !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(images) { noteImage in
                            if let image = noteImage.image {
                                ImageThumbnail(image: image, onDelete: {
                                    if let index = images.firstIndex(where: { $0.id == noteImage.id }) {
                                        images.remove(at: index)
                                    }
                                }, onExtractText: {
                                    extractText(from: image)
                                })
                            }
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $selectedItems,
                        matching: .images,
                        photoLibrary: .shared()) {
                Label("Añadir imágenes", systemImage: "photo.on.rectangle.angled")
            }
            .onChange(of: selectedItems) { items in
                Task {
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                images.append(Note.NoteImage(imageData: data))
                            }
                        }
                    }
                    selectedItems.removeAll()
                }
            }
        }
        .overlay {
            if isProcessingOCR {
                ProgressView("Procesando imagen...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
        .alert("Texto Extraído", isPresented: $showingOCRAlert) {
            Button("Añadir al contenido") {
                content += "\n\n" + ocrResult
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text(ocrResult)
        }
        .alert("No se pudo extraer texto", isPresented: $showingErrorAlert) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func extractText(from image: UIImage) {
        isProcessingOCR = true
        
        Task {
            if let extractedText = await OCRHelper.extractText(from: image) {
                await MainActor.run {
                    if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "No se ha detectado texto en esta imagen. Asegúrate de que la imagen contenga texto claro y legible."
                        showingErrorAlert = true
                    } else {
                        ocrResult = extractedText
                        showingOCRAlert = true
                    }
                    isProcessingOCR = false
                }
            } else {
                await MainActor.run {
                    errorMessage = "Ha ocurrido un error al procesar la imagen. Por favor, intenta con otra imagen o más tarde."
                    showingErrorAlert = true
                    isProcessingOCR = false
                }
            }
        }
    }
}

struct ImageThumbnail: View {
    let image: UIImage
    let onDelete: () -> Void
    let onExtractText: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack(spacing: 8) {
                Button(action: onExtractText) {
                    Image(systemName: "text.viewfinder")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.8))
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isHovering ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
                .onHover { hovering in
                    isHovering = hovering
                }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        )
                }
            }
            .padding(4)
        }
    }
} 