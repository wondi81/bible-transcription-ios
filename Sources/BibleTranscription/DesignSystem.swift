import SwiftUI

// 로드맵 확정 디자인시스템: Neumorphism · Lavender + Green · 세리프+산세리프 대비.
// 원안(Lora+Raleway)은 라틴 전용이라 한글 UI에 전혀 적용되지 않아(자동 시스템폰트 폴백),
// 실측 검증 중 발견 후 한글 지원 폰트로 교체(대표님 확인): Noto Serif KR(제목) + Pretendard(본문).
enum AppTheme {
    static let background = Color(red: 0.94, green: 0.93, blue: 0.98)
    static let lavender = Color(red: 0.60, green: 0.52, blue: 0.82)
    static let green = Color(red: 0.36, green: 0.58, blue: 0.42)
    static let textPrimary = Color(red: 0.18, green: 0.17, blue: 0.24)
}

extension Font {
    static func appTitle(_ size: CGFloat = 24) -> Font { .custom("NotoSerifKR", size: size).bold() }
    static func appBody(_ size: CGFloat = 16) -> Font { .custom("Pretendard-Regular", size: size) }
}

// Neumorphism: 밝은/어두운 그림자를 반대 방향으로 겹쳐 배경에서 볼록하게 튀어나온 느낌을 낸다.
struct NeumorphicCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .white.opacity(0.8), radius: 6, x: -6, y: -6)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 6, y: 6)
    }
}

extension View {
    func neumorphic(cornerRadius: CGFloat = 16) -> some View {
        modifier(NeumorphicCard(cornerRadius: cornerRadius))
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.appBody(16))
            .foregroundStyle(AppTheme.green)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .white.opacity(pressed ? 0.3 : 0.8), radius: pressed ? 3 : 6, x: pressed ? -2 : -6, y: pressed ? -2 : -6)
            .shadow(color: .black.opacity(pressed ? 0.08 : 0.15), radius: pressed ? 3 : 6, x: pressed ? 2 : 6, y: pressed ? 2 : 6)
    }
}
