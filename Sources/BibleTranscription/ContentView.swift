import SwiftUI
import PencilKit
import SwiftData

struct ContentView: View {
    @AppStorage("selectedTranslation") private var selectedTranslation = ""
    @Environment(\.modelContext) private var modelContext

    // CI 시뮬레이터에서 온보딩 탭 없이 홈 화면까지 자동 진입시키기 위한 스위치.
    // 실제 사용자 빌드에는 이 환경변수가 없으니 온보딩 동작은 그대로 유지된다.
    private var isCIAutoSeed: Bool {
        ProcessInfo.processInfo.environment["CI_AUTO_SEED"] == "1"
    }

    var body: some View {
        if selectedTranslation.isEmpty && !isCIAutoSeed {
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
            .task {
                await seedBibleIfNeeded()
            }
        }
    }

    @MainActor
    private func seedBibleIfNeeded() async {
        let descriptor = FetchDescriptor<Verse>()
        if let existingVerse = try? modelContext.fetch(descriptor).first {
            if existingVerse.book == "요한복음" { // 이미 시딩됨
                return
            }
        }

        guard let url = Bundle.main.url(forResource: "bible_krv", withExtension: "json") else {
            print("[SEED] JSON 파일을 찾을 수 없음")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let seeds = try JSONDecoder().decode([VerseSeed].self, from: data)
            for seed in seeds {
                let verse = Verse(
                    book: seed.book,
                    chapter: seed.chapter,
                    verseNumber: seed.verseNumber,
                    translation: seed.translation,
                    text: seed.text
                )
                modelContext.insert(verse)
            }
            try modelContext.save()
            print("[SEED] inserted \(seeds.count) verses")
        } catch {
            print("[SEED] Error: \(error)")
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
                TranscriptionScreen(
                    bookName: today.book,
                    chapter: today.chapter,
                    verseNumber: today.verseNumber,
                    verseRef: today.ref
                )
            }
            .task {
                if ProcessInfo.processInfo.environment["CI_AUTO_SEED"] == "1" {
                    showTranscription = true
                }
            }
        }
    }
}

struct TranscriptionScreen: View {
    let bookName: String
    let chapter: Int
    let verseNumber: Int
    let verseRef: String
    @State private var drawing = PKDrawing()
    @State private var verseText: String = ""
    @State private var isSubmitting = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var bookProgresses: [BookProgress]
    @Query private var allTranscriptions: [Transcription]

    private var verseTextLoaded: Bool {
        !verseText.isEmpty && verseText != "본문을 불러올 수 없습니다"
    }

    var body: some View {
        VStack {
            Text(verseRef)
                .font(.appTitle(20))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.top)
            Text(verseText)
                .font(.appBody(16))
                .foregroundStyle(AppTheme.textPrimary)
                .padding()
                .frame(maxHeight: 150)
            Text("개역한글판")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.textPrimary.opacity(0.6))
            TranscriptionCanvasView(drawing: $drawing)
                .neumorphic(cornerRadius: 12)
                .padding()
            Button("완료") { complete() }
                .buttonStyle(NeumorphicButtonStyle())
                .disabled(drawing.strokes.isEmpty || !verseTextLoaded || isSubmitting)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .navigationTitle("필사")
        .task {
            await loadVerseText()
        }
    }

    // 같은 구절을 다시 필사해도 기록(반복 연습)은 남기되, 진행률 카운트는
    // 그 구절을 "최초로" 완료했을 때만 1회 증가시켜 중복 집계를 막는다.
    // isSubmitting 가드: 버튼이 disabled로 바뀌기 전 짧은 순간 연타되면 Transcription이
    // 중복 삽입되고 completedVerses가 2번 늘어날 수 있어 재진입을 막는다.
    private func complete() {
        guard !isSubmitting else { return }
        isSubmitting = true
        let alreadyCompleted = allTranscriptions.contains { $0.verseRef == verseRef && $0.isCompleted }
        modelContext.insert(Transcription(verseRef: verseRef, drawingData: drawing.dataRepresentation(), isCompleted: true))
        if !alreadyCompleted, let progress = bookProgresses.first(where: { $0.book == bookName }) {
            progress.completedVerses += 1
        }
        dismiss()
    }

    @MainActor
    private func loadVerseText() async {
        let descriptor = FetchDescriptor<Verse>(
            predicate: #Predicate {
                $0.book == bookName && $0.chapter == chapter && $0.verseNumber == verseNumber
            }
        )
        if let verse = try? modelContext.fetch(descriptor).first {
            verseText = verse.text
            print("[TODAY-VERSE] \(bookName) \(chapter):\(verseNumber) -> \(verse.text)")
        } else {
            verseText = "본문을 불러올 수 없습니다"
            print("[TODAY-VERSE] NOT FOUND: \(bookName) \(chapter):\(verseNumber)")
        }
    }
}

#Preview {
    ContentView()
}
