#!/usr/bin/env python3
"""
개역한글판 성경 데이터 수집 및 파싱 스크립트
위키문헌(ko.wikisource.org)에서 개역한글판 성경을 수집해 JSON 형식으로 변환
"""

import json
import re
import time
import urllib.request
import urllib.parse
from typing import List, Dict, Optional, Tuple

# BibleBooks.swift의 66개 책 이름 (순서대로)
BOOK_NAMES = [
    "창세기", "출애굽기", "레위기", "민수기", "신명기", "여호수아",
    "사사기", "룻기", "사무엘상", "사무엘하", "열왕기상", "열왕기하",
    "역대상", "역대하", "에스라", "느헤미야", "에스더", "욥기",
    "시편", "잠언", "전도서", "아가", "이사야", "예레미야",
    "예레미야애가", "에스겔", "다니엘", "호세아", "요엘", "아모스",
    "오바댜", "요나", "미가", "나훔", "하박국", "스바냐",
    "학개", "스가랴", "말라기",
    "마태복음", "마가복음", "누가복음", "요한복음",
    "사도행전", "로마서", "고린도전서", "고린도후서", "갈라디아서", "에베소서",
    "빌립보서", "골로새서", "데살로니가전서", "데살로니가후서", "디모데전서", "디모데후서",
    "디도서", "빌레몬서", "히브리서", "야고보서", "베드로전서", "베드로후서",
    "요한일서", "요한이서", "요한삼서", "유다서", "요한계시록",
]


def fetch_book_list() -> List[str]:
    """위키문헌에서 개역한글판 책 목록 받기 (재귀적 continue 포함)"""
    base_url = "https://ko.wikisource.org/w/api.php"
    all_pages = []
    apcontinue = None

    while True:
        params = {
            "action": "query",
            "list": "allpages",
            "apprefix": "개역한글판/",
            "aplimit": "500",
            "format": "json"
        }
        if apcontinue:
            params["apcontinue"] = apcontinue

        query_string = urllib.parse.urlencode(params)
        url = f"{base_url}?{query_string}"

        print(f"[API] 책 목록 받기: {url[:80]}...")
        try:
            headers = {"User-Agent": "Mozilla/5.0 (compatible; BibleBot/1.0)"}
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=10) as response:
                data = json.loads(response.read().decode('utf-8'))
                pages = data.get("query", {}).get("allpages", [])
                all_pages.extend(pages)
                print(f"  → {len(pages)}개 페이지 수신 (누적: {len(all_pages)}개)")
        except Exception as e:
            print(f"[ERROR] API 요청 실패: {e}")
            raise

        # continue 토큰 확인
        apcontinue = data.get("continue", {}).get("apcontinue")
        if not apcontinue:
            break
        time.sleep(0.3)

    # 페이지명 추출 ("개역한글판/창세기" → "창세기")
    book_list = [p["title"].replace("개역한글판/", "") for p in all_pages]
    print(f"\n[검증] 총 {len(book_list)}개 책 수신")

    if len(book_list) != 66:
        print(f"[WARNING] 예상 66개가 아니라 {len(book_list)}개입니다!")

    return book_list


def get_wikitext(page_title: str) -> str:
    """각 책의 wikitext 원문 받기"""
    url = f"https://ko.wikisource.org/w/index.php?title={urllib.parse.quote(page_title)}&action=raw"

    headers = {"User-Agent": "Mozilla/5.0 (compatible; BibleBot/1.0)"}
    req = urllib.request.Request(url, headers=headers)

    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            return response.read().decode('utf-8')
    except Exception as e:
        print(f"[ERROR] {page_title} 원문 수신 실패: {e}")
        raise


def parse_verses(wikitext: str, book_name: str) -> List[Tuple[int, int, str]]:
    """
    wikitext를 파싱해서 (장, 절, 본문) 튜플 리스트 반환

    장 구분: == N장 ==
    절 구분: {{절|장|절}} 또는 {{절||절}} 또는 {{절|장}} (절 번호 없으면 1절)
    """
    verses = []

    # 메타 템플릿 제거 (상단)
    wikitext = re.sub(r'\{\{다른 번역본\|[^}]*\}\}', '', wikitext)
    wikitext = re.sub(r'\{\{머리말\|[^}]*\}\}', '', wikitext)
    wikitext = re.sub(r'\{\{주석\|[^}]*\}\}', '', wikitext)

    # 현재 장번호 추적
    current_chapter = 0

    # 각 줄 처리
    lines = wikitext.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i]

        # 장 헤더 찾기 (== N장 ==)
        chapter_match = re.match(r'^==\s*(\d+)\s*장\s*==$', line.strip())
        if chapter_match:
            current_chapter = int(chapter_match.group(1))
            i += 1
            continue

        # 절 템플릿 찾기 ({{절|...}})
        # 패턴: {{절|장|절}} 또는 {{절||절}} 또는 {{절|장}} 또는 {{절|장|}}
        verse_match = re.search(r'\{\{절\|([^}]*)\}\}', line)
        if verse_match:
            parts = verse_match.group(1).split('|')

            verse_chapter = current_chapter
            verse_number = 1  # 기본값

            if len(parts) >= 2:
                # {{절|장|절}} 형태
                if parts[0]:  # 장 번호가 있음
                    verse_chapter = int(parts[0])
                if parts[1]:  # 절 번호가 있음
                    verse_number = int(parts[1])
                else:  # 절 번호 없으면 1절
                    verse_number = 1
            elif len(parts) == 1:
                # {{절|장}} 또는 {{절||}} 형태
                if parts[0]:  # 장 번호가 있음
                    verse_chapter = int(parts[0])
                    verse_number = 1
                else:  # {{절||}} 형태 (이건 이미 처리됐으므로 패스)
                    pass

            # 절 템플릿 이후부터 다음 절 또는 장 헤더 전까지 = 본문
            verse_text_lines = []
            start_pos = verse_match.end()
            j = i

            while j < len(lines):
                next_line = lines[j]

                # 다음 절 또는 장 헤더 확인
                if re.search(r'\{\{절\|', next_line):
                    # 다음 절 시작
                    verse_text = line[start_pos:].strip() + '\n' + '\n'.join(verse_text_lines)
                    break
                elif re.match(r'^==\s*\d+\s*장\s*==$', next_line.strip()):
                    # 다음 장 시작
                    verse_text = line[start_pos:].strip() + '\n' + '\n'.join(verse_text_lines)
                    break

                if j > i:  # 첫 줄 아닐 때만 추가
                    verse_text_lines.append(next_line)
                j += 1
            else:
                # 파일 끝까지 갔을 때
                verse_text = line[start_pos:].strip() + '\n' + '\n'.join(verse_text_lines)

            # 마크업 제거
            verse_text = clean_markup(verse_text).strip()

            if verse_text:  # 본문이 있을 때만 추가
                verses.append((verse_chapter, verse_number, verse_text))

        i += 1

    return verses


def clean_markup(text: str) -> str:
    """마크업 제거"""
    # [[...]] 위키링크 (표시 텍스트만 유지)
    text = re.sub(r'\[\[([^\]|]*)\|?([^\]]*)\]\]', r'\2 or \1', text)
    text = re.sub(r'\[\[([^\]]*)\]\]', r'\1', text)

    # ''...'' 이탤릭 (따옴표 제거, 텍스트 유지)
    text = re.sub(r"''([^']*)''", r'\1', text)

    # <ref>...</ref> 각주
    text = re.sub(r'<ref[^>]*>.*?</ref>', '', text, flags=re.DOTALL)

    # <!-- --> HTML 주석
    text = re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)

    # 다중 공백/개행 정리
    text = re.sub(r'\s+', ' ', text)

    return text.strip()


def map_books_to_app_names(wiki_books: List[str]) -> Dict[str, str]:
    """
    위키문헌 책 이름을 앱(BibleBooks.swift)의 책 이름으로 매핑

    예: "요한1서" → "요한일서"
    """
    mapping = {}

    # 숫자 표기를 한글로 변환하는 헬퍼
    number_to_korean = {
        '1': '일', '2': '이', '3': '삼', '4': '사', '5': '오',
    }

    for wiki_name in wiki_books:
        # 기본: 정확히 일치하는 경우
        if wiki_name in BOOK_NAMES:
            mapping[wiki_name] = wiki_name
        else:
            # "요한1서" → "요한일서" 변환 시도
            normalized = wiki_name
            for digit, korean in number_to_korean.items():
                normalized = normalized.replace(digit, korean)

            if normalized in BOOK_NAMES:
                mapping[wiki_name] = normalized
            else:
                print(f"[WARNING] 매핑 실패: {wiki_name} (정규화: {normalized})")

    return mapping


def main():
    print("=" * 60)
    print("개역한글판 성경 데이터 수집 시작")
    print("=" * 60)

    # 1. 책 목록 받기
    print("\n[단계 1] 위키문헌에서 책 목록 수신...")
    wiki_books = fetch_book_list()

    # 2. 책 이름 매핑
    print("\n[단계 2] 책 이름 매핑...")
    book_mapping = map_books_to_app_names(wiki_books)

    unmapped = [b for b in wiki_books if b not in book_mapping]
    if unmapped:
        print(f"[ERROR] 매핑 실패한 책: {unmapped}")
        return

    print(f"  → {len(book_mapping)}개 책 매핑 완료")

    # 3. 각 책의 wikitext 파싱
    print("\n[단계 3] 성경 원문 수집 및 파싱...")
    all_verses = []
    errors = []

    for i, wiki_name in enumerate(wiki_books, 1):
        app_name = book_mapping[wiki_name]
        print(f"  [{i:2d}/{len(wiki_books)}] {app_name}...", end=" ", flush=True)

        try:
            wikitext = get_wikitext(f"개역한글판/{wiki_name}")
            verses = parse_verses(wikitext, app_name)

            for chapter, verse_num, text in verses:
                all_verses.append({
                    "book": app_name,
                    "chapter": chapter,
                    "verseNumber": verse_num,
                    "translation": "개역한글판",
                    "text": text
                })

            print(f"{len(verses)}절")
            time.sleep(0.3)  # API rate limit
        except Exception as e:
            print(f"ERROR: {e}")
            errors.append((app_name, str(e)))

    # 4. JSON 저장
    print(f"\n[단계 4] JSON 저장...")
    output_dir = "Sources/BibleTranscription/Resources"
    import os
    os.makedirs(output_dir, exist_ok=True)

    output_file = f"{output_dir}/bible_krv.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_verses, f, ensure_ascii=False, indent=2)

    file_size = os.path.getsize(output_file)
    print(f"  → {output_file} 저장 완료 ({file_size:,} bytes)")

    # 5. 검증
    print("\n" + "=" * 60)
    print("검증 결과")
    print("=" * 60)

    print(f"\n1. 총 책 수: {len(book_mapping)} (예상: 66)")
    if len(book_mapping) != 66:
        print(f"   [ERROR] 책 수가 맞지 않습니다!")
    else:
        print(f"   [OK] 정확히 66개")

    print(f"\n2. 총 절 수: {len(all_verses)}절")
    print(f"   (참고: 개역한글판 전체 약 30,000절)")

    # 스팟 체크
    print(f"\n3. 스팟 체크:")
    spot_checks = [
        ("창세기", 1, 1),
        ("요한복음", 3, 16),
        ("시편", 23, 1),
    ]

    for book, chapter, verse_num in spot_checks:
        matching = [v for v in all_verses
                   if v["book"] == book and v["chapter"] == chapter and v["verseNumber"] == verse_num]
        if matching:
            text = matching[0]["text"]
            print(f"   {book} {chapter}:{verse_num}")
            print(f"   → \"{text[:60]}...\"" if len(text) > 60 else f"   → \"{text}\"")
        else:
            print(f"   {book} {chapter}:{verse_num} - NOT FOUND")

    if errors:
        print(f"\n4. 파싱 오류: {len(errors)}건")
        for book, error in errors:
            print(f"   {book}: {error}")
    else:
        print(f"\n4. 파싱 오류: 0건")

    print("\n" + "=" * 60)
    print("완료!")
    print("=" * 60)


if __name__ == "__main__":
    main()
