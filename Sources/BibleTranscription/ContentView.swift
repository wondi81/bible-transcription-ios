import SwiftUI
import PencilKit
import SwiftData

struct ContentView: View {
    @AppStorage("selectedTranslation") private var selectedTranslation = ""

    var body: some View {
        if selectedTranslation.isEmpty {
            OnboardingView()
        } else {
            TabView {
                HomeScreen()
                    .tabItem { Label("홈", systemImage: "house") }
                ProgressScreen()
                    .tabItem { Label("진행률", systemImage: "chart.bar") }
                ArchiveScreen()
                    .tabItem { Label("기록보관함", systemImage: "tray.full") }
            }
        }
    }
}

struct HomeScreen: View {
    @State private var showTranscription = false
    // ponytail: 오늘의 구절 로테이션 로직은 아직 없음, 우선 고정 구절로 화면 골격만 검증.
    private let todayBook = "요한복음"
    private let todayVerseRef = "요한복음 3:16"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("오늘의 구절")
                    .font(.headline)
                Text(todayVerseRef)
                    .font(.title2.bold())
                Button("필사 시작") {
                    showTranscription = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("성경필사")
            .navigationDestination(isPresented: $showTranscription) {
                TranscriptionScreen(verseRef: todayVerseRef, bookName: todayBook)
            }
        }
    }
}

struct TranscriptionScreen: View {
    let verseRef: String
    let bookName: String
    @State private var drawing = PKDrawing()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var bookProgresses: [BookProgress]

    var body: some View {
        VStack {
            Text(verseRef).font(.headline).padding(.top)
            TranscriptionCanvasView(drawing: $drawing)
                .border(Color.gray.opacity(0.3))
            Button("완료") { complete() }
                .buttonStyle(.borderedProminent)
                .padding()
        }
        .navigationTitle("필사")
    }

    // ponytail: 같은 구절 재필사 시 완료 카운트 중복 증가 방지는 아직 없음 —
    // 진행률 정확도가 QA 최우선 항목(설계문서)이라 P0 나머지 화면 완성 후 반드시 보완.
    private func complete() {
        modelContext.insert(Transcription(verseRef: verseRef, drawingData: drawing.dataRepresentation(), isCompleted: true))
        if let progress = bookProgresses.first(where: { $0.book == bookName }) {
            progress.completedVerses += 1
        }
        dismiss()
    }
}

#Preview {
    ContentView()
}
