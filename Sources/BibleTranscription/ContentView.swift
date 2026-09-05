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
    private let today = TodayVerse.today

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("오늘의 구절")
                    .font(.appBody(15))
                    .foregroundStyle(AppTheme.textPrimary.opacity(0.7))
                Text(today.ref)
                    .font(.appTitle(26))
                    .foregroundStyle(AppTheme.textPrimary)
                Button("필사 시작") {
                    showTranscription = true
                }
                .buttonStyle(NeumorphicButtonStyle())
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background)
            .navigationTitle("성경필사")
            .navigationDestination(isPresented: $showTranscription) {
                TranscriptionScreen(verseRef: today.ref, bookName: today.book)
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
    @Query private var allTranscriptions: [Transcription]

    var body: some View {
        VStack {
            Text(verseRef)
                .font(.appTitle(20))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.top)
            TranscriptionCanvasView(drawing: $drawing)
                .neumorphic(cornerRadius: 12)
                .padding()
            Button("완료") { complete() }
                .buttonStyle(NeumorphicButtonStyle())
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .navigationTitle("필사")
    }

    // 같은 구절을 다시 필사해도 기록(반복 연습)은 남기되, 진행률 카운트는
    // 그 구절을 "최초로" 완료했을 때만 1회 증가시켜 중복 집계를 막는다.
    private func complete() {
        let alreadyCompleted = allTranscriptions.contains { $0.verseRef == verseRef && $0.isCompleted }
        modelContext.insert(Transcription(verseRef: verseRef, drawingData: drawing.dataRepresentation(), isCompleted: true))
        if !alreadyCompleted, let progress = bookProgresses.first(where: { $0.book == bookName }) {
            progress.completedVerses += 1
        }
        dismiss()
    }
}

#Preview {
    ContentView()
}
