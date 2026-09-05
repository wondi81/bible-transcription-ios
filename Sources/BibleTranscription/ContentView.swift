import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var showTranscription = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("오늘의 구절")
                    .font(.headline)
                Text("요한복음 3:16")
                    .font(.title2.bold())
                Button("필사 시작") {
                    showTranscription = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("성경필사")
            .navigationDestination(isPresented: $showTranscription) {
                TranscriptionScreen(verseRef: "요한복음 3:16")
            }
        }
    }
}

struct TranscriptionScreen: View {
    let verseRef: String
    @State private var drawing = PKDrawing()

    var body: some View {
        VStack {
            Text(verseRef).font(.headline).padding(.top)
            TranscriptionCanvasView(drawing: $drawing)
                .border(Color.gray.opacity(0.3))
        }
        .navigationTitle("필사")
    }
}

#Preview {
    ContentView()
}
