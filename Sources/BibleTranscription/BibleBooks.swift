import Foundation

struct BibleBookRef {
    let name: String
    let totalVerses: Int
}

enum BibleBooks {
    // ponytail: 절수는 영어 표준역(ESV) 기준 참고값. 개역개정 원문과 일부 책(시편 표제 등)에서
    // 1~2절 오차가 있을 수 있어, 정식 출시 전 개역개정 원문 대조로 재검증 필요.
    static let all: [BibleBookRef] = [
        .init(name: "창세기", totalVerses: 1533), .init(name: "출애굽기", totalVerses: 1213),
        .init(name: "레위기", totalVerses: 859), .init(name: "민수기", totalVerses: 1288),
        .init(name: "신명기", totalVerses: 959), .init(name: "여호수아", totalVerses: 658),
        .init(name: "사사기", totalVerses: 618), .init(name: "룻기", totalVerses: 85),
        .init(name: "사무엘상", totalVerses: 810), .init(name: "사무엘하", totalVerses: 695),
        .init(name: "열왕기상", totalVerses: 816), .init(name: "열왕기하", totalVerses: 719),
        .init(name: "역대상", totalVerses: 942), .init(name: "역대하", totalVerses: 822),
        .init(name: "에스라", totalVerses: 280), .init(name: "느헤미야", totalVerses: 406),
        .init(name: "에스더", totalVerses: 167), .init(name: "욥기", totalVerses: 1070),
        .init(name: "시편", totalVerses: 2461), .init(name: "잠언", totalVerses: 915),
        .init(name: "전도서", totalVerses: 222), .init(name: "아가", totalVerses: 117),
        .init(name: "이사야", totalVerses: 1292), .init(name: "예레미야", totalVerses: 1364),
        .init(name: "예레미야애가", totalVerses: 154), .init(name: "에스겔", totalVerses: 1273),
        .init(name: "다니엘", totalVerses: 357), .init(name: "호세아", totalVerses: 197),
        .init(name: "요엘", totalVerses: 73), .init(name: "아모스", totalVerses: 146),
        .init(name: "오바댜", totalVerses: 21), .init(name: "요나", totalVerses: 48),
        .init(name: "미가", totalVerses: 105), .init(name: "나훔", totalVerses: 47),
        .init(name: "하박국", totalVerses: 56), .init(name: "스바냐", totalVerses: 53),
        .init(name: "학개", totalVerses: 38), .init(name: "스가랴", totalVerses: 211),
        .init(name: "말라기", totalVerses: 55),
        .init(name: "마태복음", totalVerses: 1067), .init(name: "마가복음", totalVerses: 673),
        .init(name: "누가복음", totalVerses: 1149), .init(name: "요한복음", totalVerses: 866),
        .init(name: "사도행전", totalVerses: 1003), .init(name: "로마서", totalVerses: 432),
        .init(name: "고린도전서", totalVerses: 437), .init(name: "고린도후서", totalVerses: 257),
        .init(name: "갈라디아서", totalVerses: 149), .init(name: "에베소서", totalVerses: 155),
        .init(name: "빌립보서", totalVerses: 104), .init(name: "골로새서", totalVerses: 95),
        .init(name: "데살로니가전서", totalVerses: 89), .init(name: "데살로니가후서", totalVerses: 47),
        .init(name: "디모데전서", totalVerses: 113), .init(name: "디모데후서", totalVerses: 83),
        .init(name: "디도서", totalVerses: 46), .init(name: "빌레몬서", totalVerses: 25),
        .init(name: "히브리서", totalVerses: 303), .init(name: "야고보서", totalVerses: 108),
        .init(name: "베드로전서", totalVerses: 105), .init(name: "베드로후서", totalVerses: 61),
        .init(name: "요한일서", totalVerses: 105), .init(name: "요한이서", totalVerses: 13),
        .init(name: "요한삼서", totalVerses: 15), .init(name: "유다서", totalVerses: 25),
        .init(name: "요한계시록", totalVerses: 404),
    ]
}
