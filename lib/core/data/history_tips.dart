/// 문서 포맷 관련 역사적 사실 데이터
/// 카테고리: PDF, HWP, DOCX, XLSX, GENERAL
library;

class HistoryTip {
  const HistoryTip({required this.category, required this.fact});

  final String category;
  final String fact;
}

const List<HistoryTip> historyTips = [
  // ============================================================
  // PDF 관련
  // ============================================================
  HistoryTip(category: 'PDF', fact: 'Adobe 창업자들은 상사가 기술 상용화를 거부해서 퇴사 후 창업했어요'),
  HistoryTip(category: 'PDF', fact: 'Adobe라는 이름은 창업자 집 뒤를 흐르는 개울 이름에서 따왔어요'),
  HistoryTip(category: 'PDF', fact: '1993년 PDF 출시 당시 뷰어 소프트웨어 가격은 695달러였어요'),
  HistoryTip(
    category: 'PDF',
    fact: 'PDF 무료 배포 결정은 Adobe 역사상 가장 성공적인 전략으로 평가받아요',
  ),
  HistoryTip(
    category: 'PDF',
    fact: 'PDF가 2008년 국제 표준이 되면서 Adobe는 관련 특허를 무료로 공개했어요',
  ),
  HistoryTip(category: 'PDF', fact: '전 세계에서 유통되는 PDF 문서 수는 약 2.5조 개로 추정돼요'),
  HistoryTip(category: 'PDF', fact: 'PDF는 출시 10년 만에 모든 경쟁 포맷을 제치고 표준이 됐어요'),
  HistoryTip(category: 'PDF', fact: 'Mac은 2001년부터 PDF를 시스템 기본 문서 포맷으로 채택했어요'),
  HistoryTip(category: 'PDF', fact: 'PDF/A는 100년 이상 장기 보존을 위한 국제 표준 포맷이에요'),
  HistoryTip(category: 'PDF', fact: 'Adobe는 현재 시가총액 2000억 달러가 넘는 거대 기업이 됐어요'),

  // ============================================================
  // HWP 관련
  // ============================================================
  HistoryTip(
    category: 'HWP',
    fact: '1989년 한글 1.0을 만든 이찬진, 김택진 등 4인은 당시 대학원생이었어요',
  ),
  HistoryTip(category: 'HWP', fact: '김택진은 한글과컴퓨터를 떠나 엔씨소프트를 창업해 리니지를 만들었어요'),
  HistoryTip(category: 'HWP', fact: '세벌식 자판을 만든 공병우 박사가 한글 개발팀에 연구 공간을 제공했어요'),
  HistoryTip(
    category: 'HWP',
    fact: '1998년 IMF 때 한글과컴퓨터가 부도 위기에 처했지만 사용자 모금으로 살아났어요',
  ),
  HistoryTip(category: 'HWP', fact: '한글 포맷은 20년 넘게 대한민국 공문서의 사실상 표준이었어요'),
  HistoryTip(category: 'HWP', fact: '한글과컴퓨터의 첫 사무실은 서울대학교 근처 작은 방이었어요'),
  HistoryTip(
    category: 'HWP',
    fact: '한글 워드프로세서는 MS Word보다 표 편집 기능이 강력하다고 평가받아요',
  ),
  HistoryTip(category: 'HWP', fact: '대한민국 공공기관 문서의 90% 이상이 HWP 포맷을 사용해요'),
  HistoryTip(category: 'HWP', fact: 'HWPX는 개방형 문서 포맷으로, 다른 프로그램에서도 읽을 수 있어요'),
  HistoryTip(category: 'HWP', fact: '한글은 국산 소프트웨어가 외산을 이긴 드문 성공 사례로 꼽혀요'),

  // ============================================================
  // DOCX 관련
  // ============================================================
  HistoryTip(
    category: 'DOCX',
    fact: 'MS Word는 1983년에 유닉스용으로 먼저 나왔고, 윈도우용은 1989년에 나왔어요',
  ),
  HistoryTip(
    category: 'DOCX',
    fact: '클리피의 본명은 클리핏이고, 사용자들의 미움을 받아 2007년에 은퇴했어요',
  ),
  HistoryTip(
    category: 'DOCX',
    fact: 'DOCX 파일은 실제로 ZIP 압축 파일이에요. 확장자를 바꾸면 열 수 있어요',
  ),
  HistoryTip(
    category: 'DOCX',
    fact: 'Word는 전 세계 5억 명 이상이 사용하는 가장 인기 있는 워드프로세서예요',
  ),
  HistoryTip(
    category: 'DOCX',
    fact: '리본 인터페이스는 2007년 오피스에서 처음 도입되어 큰 논란을 일으켰어요',
  ),
  HistoryTip(category: 'DOCX', fact: 'Microsoft는 1975년 빌 게이츠와 폴 앨런이 창업했어요'),
  HistoryTip(
    category: 'DOCX',
    fact: 'Word 초기 버전은 마우스 없이 키보드만으로 모든 작업을 할 수 있게 설계됐어요',
  ),
  HistoryTip(category: 'DOCX', fact: '타임스 뉴 로만 폰트는 1931년 런던 타임스 신문을 위해 만들어졌어요'),
  HistoryTip(
    category: 'DOCX',
    fact: '코믹 산스 폰트는 1994년 마이크로소프트 밥의 말풍선용으로 만들어졌어요',
  ),

  // ============================================================
  // XLSX 관련
  // ============================================================
  HistoryTip(category: 'XLSX', fact: 'Excel은 원래 맥 전용이었고, 윈도우보다 맥에서 먼저 성공했어요'),
  HistoryTip(category: 'XLSX', fact: 'Excel 월드 챔피언십이라는 공식 e스포츠 대회가 있어요'),
  HistoryTip(
    category: 'XLSX',
    fact: 'Excel은 1,048,576행까지 지원하는데, 이는 2의 20제곱이에요',
  ),
  HistoryTip(
    category: 'XLSX',
    fact: 'Excel로 게임을 만드는 사람들이 있어요. 둠도 Excel에서 실행된 적 있어요',
  ),
  HistoryTip(category: 'XLSX', fact: 'XLSX도 DOCX처럼 실제로는 ZIP 압축 파일이에요'),
  HistoryTip(category: 'XLSX', fact: '금융업계에서 Excel은 수조 달러 규모의 거래를 관리하는 데 사용돼요'),
  HistoryTip(category: 'XLSX', fact: 'Excel 셀 하나에 32,767자까지 입력할 수 있어요'),
  HistoryTip(category: 'XLSX', fact: 'Excel의 첫 버전은 1985년에 출시됐어요'),

  // ============================================================
  // GENERAL - 종이/인쇄/문서/타자기/컴퓨터 역사
  // ============================================================

  // 고대 문자와 기록
  HistoryTip(category: 'GENERAL', fact: '기원전 3200년경 메소포타미아에서 인류 최초의 문자가 발명됐어요'),
  HistoryTip(category: 'GENERAL', fact: '고대 메소포타미아에서는 갈대 펜으로 점토판에 글자를 새겼어요'),
  HistoryTip(category: 'GENERAL', fact: '이집트 상형문자는 기원전 3000년경부터 사용됐어요'),
  HistoryTip(category: 'GENERAL', fact: '로제타석 덕분에 1822년에 이집트 상형문자를 해독할 수 있었어요'),
  HistoryTip(category: 'GENERAL', fact: '사해문서는 1947년 양치기 소년이 동굴에서 우연히 발견했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '알렉산드리아 도서관은 70만 권의 두루마리를 소장한 고대 최대 도서관이었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '알렉산드리아 도서관 화재로 인류 지식의 상당 부분이 영원히 사라졌어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '중국 한나라의 채륜이 105년경 현대적 종이 제조법을 발명했어요'),

  // 인쇄술의 역사
  HistoryTip(
    category: 'GENERAL',
    fact: '868년 중국에서 인쇄된 금강경이 현존하는 가장 오래된 인쇄물이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '금강경은 현재 영국 국립도서관에 보관돼 있어요'),
  HistoryTip(category: 'GENERAL', fact: '1234년 고려에서 세계 최초로 금속활자가 발명됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1377년 인쇄된 직지심체요절은 구텐베르크보다 78년 앞선 세계 최초 금속활자본이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '직지심체요절은 유네스코 세계기록유산이며 프랑스 국립도서관에 있어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1455년 구텐베르크 성경은 180부 인쇄됐고, 현재 49부가 남아있어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '구텐베르크 성경 한 권은 경매에서 500만 달러 이상에 거래됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '구텐베르크 인쇄술로 책 가격이 80% 이상 떨어져 지식 대중화가 시작됐어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '15세기 베네치아는 유럽 인쇄술의 중심지로, 150개 이상의 인쇄소가 있었어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '이탤릭체는 책을 더 작게 만들기 위해 개발된 글씨체예요'),

  // 한글과 동아시아 문자
  HistoryTip(
    category: 'GENERAL',
    fact: '1443년 세종대왕이 훈민정음을 창제했어요. 창제 원리가 기록된 유일한 문자예요',
  ),
  HistoryTip(category: 'GENERAL', fact: '한글 자음은 혀, 입술 등 발음 기관의 모양을 본떠 만들었어요'),
  HistoryTip(category: 'GENERAL', fact: '훈민정음 해례본은 1940년 안동에서 발견됐고, 국보 제70호예요'),
  HistoryTip(category: 'GENERAL', fact: '일본어 히라가나와 가타카나는 한자를 간략화해서 만든 문자예요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '한자는 3,000년 이상 사용된 세계에서 가장 오래된 문자 체계 중 하나예요',
  ),

  // 필기구
  HistoryTip(category: 'GENERAL', fact: '1938년 헝가리의 신문기자가 볼펜을 발명했어요'),
  HistoryTip(category: 'GENERAL', fact: '1945년 뉴욕 백화점에서 볼펜이 첫날 3만 개가 팔렸어요'),
  HistoryTip(category: 'GENERAL', fact: '연필심은 사실 납이 아니라 흑연이에요'),
  HistoryTip(category: 'GENERAL', fact: '1564년 영국에서 흑연 광맥이 발견되며 연필의 역사가 시작됐어요'),

  // 타자기와 키보드
  HistoryTip(category: 'GENERAL', fact: '1868년에 QWERTY 키보드가 발명됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: 'QWERTY 배열은 타자기 레버가 엉키지 않도록 자주 쓰는 글자를 떨어뜨린 거예요',
  ),
  HistoryTip(category: 'GENERAL', fact: 'Shift 키는 1878년에 추가되어 대소문자 전환이 가능해졌어요'),
  HistoryTip(category: 'GENERAL', fact: '타자기 덕분에 19세기 후반 여성의 사무직 진출이 크게 늘었어요'),
  HistoryTip(category: 'GENERAL', fact: 'QWERTY 키보드는 150년 넘게 표준으로 사용되고 있어요'),
  HistoryTip(category: 'GENERAL', fact: '타이핑 세계 기록은 1분에 216단어예요'),

  // 종이 규격
  HistoryTip(category: 'GENERAL', fact: 'A4 용지 비율은 반으로 접어도 같은 비율이 유지되도록 설계됐어요'),
  HistoryTip(category: 'GENERAL', fact: 'A0 용지 면적은 정확히 1제곱미터예요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '미국과 캐나다만 레터 사이즈를 쓰고, 나머지 세계는 A4를 사용해요',
  ),
  HistoryTip(category: 'GENERAL', fact: 'A4 용지 한 장을 만드는 데 약 10리터의 물이 필요해요'),
  HistoryTip(category: 'GENERAL', fact: '전 세계 종이 생산량은 연간 4억 톤이 넘어요'),
  HistoryTip(category: 'GENERAL', fact: '종이는 약 5~7번 재활용할 수 있어요'),

  // 점자
  HistoryTip(category: 'GENERAL', fact: '1824년 15세의 루이 브라유가 점자를 발명했어요'),
  HistoryTip(category: 'GENERAL', fact: '점자는 군대 야간 통신용 코드에서 영감을 받았어요'),
  HistoryTip(category: 'GENERAL', fact: '숙련된 점자 독자는 분당 200단어를 읽을 수 있어요'),
  HistoryTip(category: 'GENERAL', fact: '루이 브라유는 3살 때 사고로 시력을 잃었어요'),

  // 컴퓨터
  HistoryTip(category: 'GENERAL', fact: '세계 최초의 컴퓨터 프로그래머 6명은 모두 여성 수학자였어요'),
  HistoryTip(category: 'GENERAL', fact: '1971년 최초의 이메일이 전송되며 @ 기호가 사용됐어요'),
  HistoryTip(category: 'GENERAL', fact: '@ 기호는 중세 수도사들이 라틴어 약자로 사용한 것이 유래예요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1979년 스티브 잡스가 제록스 연구소를 방문하고 GUI의 가능성에 열광했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '1968년에 마우스가 처음 공개됐어요'),
  HistoryTip(category: 'GENERAL', fact: '1984년 매킨토시는 GUI를 대중화한 첫 번째 컴퓨터였어요'),

  // 인터넷과 웹
  HistoryTip(category: 'GENERAL', fact: '1991년 월드 와이드 웹이 공개됐어요'),
  HistoryTip(category: 'GENERAL', fact: 'HTML의 H는 하이퍼텍스트의 약자로, 문서 간 연결을 의미해요'),
  HistoryTip(category: 'GENERAL', fact: '2006년 구글 문서도구가 출시되며 클라우드 문서 시대가 열렸어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '위키피디아는 2001년 시작해 현재 6천만 개 이상의 문서를 보유해요',
  ),

  // 유명 문서들
  HistoryTip(category: 'GENERAL', fact: '1215년 마그나 카르타는 왕도 법 아래 있다는 원칙을 세웠어요'),
  HistoryTip(category: 'GENERAL', fact: '마그나 카르타 원본은 4부만 현존해요'),
  HistoryTip(category: 'GENERAL', fact: '1776년 미국 독립선언서는 마그나 카르타의 영향을 받았어요'),
  HistoryTip(category: 'GENERAL', fact: '레오나르도 다빈치의 노트는 왼손잡이용 거울 글씨로 쓰여졌어요'),
  HistoryTip(category: 'GENERAL', fact: '보이니치 문서는 15세기 작품으로 아직도 해독되지 않았어요'),

  // 폰트
  HistoryTip(
    category: 'GENERAL',
    fact: '헬베티카 폰트는 1957년 스위스에서 만들어져 세계에서 가장 많이 쓰이는 폰트가 됐어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '코믹 산스는 디자이너들에게 미움받지만, 난독증 환자에게는 읽기 쉬워요',
  ),

  // 중세 필사본
  HistoryTip(category: 'GENERAL', fact: '중세 수도원에서 수도사들이 손으로 책을 베껴썼어요'),
  HistoryTip(category: 'GENERAL', fact: '한 권의 성경을 베끼는 데 수도사 1명이 1년 이상 걸렸어요'),
  HistoryTip(category: 'GENERAL', fact: '중세 필사본의 양피지는 양이나 송아지 가죽으로 만들었어요'),

  // 재미있는 사실들
  HistoryTip(
    category: 'GENERAL',
    fact: '1221년 신성로마제국 황제가 공문서에 종이 사용을 금지했어요 (양피지가 고급이라서)',
  ),
  HistoryTip(category: 'GENERAL', fact: '이탈리아 파브리아노는 12세기부터 워터마크를 발명한 도시예요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1844년 나무 펄프로 종이를 만드는 기술이 발명되며 가격이 급락했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '유니코드는 전 세계 모든 문자를 표현할 수 있어 현재 15만 개 이상의 문자를 지원해요',
  ),
  HistoryTip(category: 'GENERAL', fact: '2007년 킨들이 출시되어 전자책 시대가 열렸어요'),
  HistoryTip(category: 'GENERAL', fact: 'Ctrl+Z 실행취소는 1974년에 발명됐어요'),
  HistoryTip(category: 'GENERAL', fact: '복사 붙여넣기는 1983년 애플 리사에서 처음 도입됐어요'),
  HistoryTip(category: 'GENERAL', fact: '세계에서 가장 긴 책은 7권으로 470만 단어가 넘어요'),
  HistoryTip(category: 'GENERAL', fact: 'PDF는 Portable Document Format의 약자예요'),

  // ============================================================
  // 추가 역사적 상식 - 고대 문명과 문자
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '숫자 0은 3~4세기 인도에서 처음 사용됐고, 아랍을 거쳐 유럽에 전해졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '고대 바빌로니아인들은 60진법을 사용했고, 지금도 시간과 각도에 그 흔적이 남아있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '이집트 상형문자는 3000년 이상 사용됐지만, 4세기 이후 아무도 읽지 못하게 됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '점토판에 새긴 설형문자는 불에 구워지면 오히려 더 오래 보존돼요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '고대 이집트에서 파피루스는 너무 비싸서 문서를 지우고 다시 쓰는 경우가 많았어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '메소포타미아에서는 계약서를 점토판에 새기고 봉투처럼 한 번 더 점토로 감쌌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '고대 그리스인들은 노예의 삭발한 머리에 메시지를 문신하고 머리가 자라면 보냈어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '스파르타 군대는 나무 막대에 가죽끈을 감아 암호를 만드는 스키탈레를 사용했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '기원전 196년에 만들어진 로제타석에는 같은 내용이 세 가지 문자로 새겨져 있어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '로제타석은 1799년 나폴레옹의 이집트 원정 중 우연히 발견됐어요'),
  HistoryTip(category: 'GENERAL', fact: '장 프랑수아 샹폴리옹은 로제타석을 해독할 때 겨우 32세였어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '마야 문자는 20세기 후반까지 해독되지 못했고, 지금도 완전히 이해되지 않았어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '중국 갑골문자는 거북이 등껍질이나 소 뼈에 새겨서 점을 치는 데 사용됐어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '페니키아 알파벳은 모든 서양 알파벳의 조상으로, 22개 자음만 있었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '고대 그리스인들이 페니키아 알파벳에 모음을 추가해서 현대 알파벳의 기초를 만들었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '룬 문자는 바이킹들이 돌이나 나무에 새기기 쉽게 직선으로만 이루어져 있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '산스크리트어는 컴퓨터 언어와 구조가 비슷해서 인공지능 연구에 영감을 줬어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '현재 사용되는 문자 체계는 전 세계에 약 300개가 넘어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '세계에서 가장 적은 글자를 가진 문자는 로토카스어로, 단 12개의 글자만 있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '크레타 섬의 선형 A 문자는 아직도 해독되지 않은 수수께끼로 남아있어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 도서관과 기록 보관
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '알렉산드리아 도서관은 입항하는 모든 배의 책을 압수해서 복사한 후 원본을 보관했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '미국 의회도서관은 세계 최대 도서관으로 1억 7천만 점 이상의 자료를 보유하고 있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '미국 의회도서관의 서가를 일렬로 늘어놓으면 약 1,350km가 넘어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '1815년 미국 의회도서관이 불타자 토머스 제퍼슨이 개인 장서 6,487권을 팔았어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '바티칸 비밀 문서고에는 85km에 달하는 서가에 1,000년 이상의 기록이 보관돼 있어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '중세 수도원 도서관은 책을 쇠사슬로 책상에 묶어두었어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '유럽 최초의 공공 도서관은 1452년 이탈리아 피렌체에 문을 열었어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '고대 니네베 도서관에서 발견된 점토판은 3만 개가 넘어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '사해 문서는 2000년 넘게 동굴에서 보존되어 성경 연구의 혁명을 일으켰어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '1972년 예멘 모스크에서 발견된 코란 사본은 1,400년 이상 된 것으로 밝혀졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '일본 최초의 소설 겐지 이야기는 1000년경 궁녀가 쓴 것으로 추정돼요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '조선왕조실록은 500년간의 역사를 기록한 세계 최장 단일 왕조 기록물이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '조선왕조실록은 화재에 대비해 전국 4곳에 분산 보관됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '영국 대영도서관에는 마그나 카르타 원본 4부 중 2부가 소장되어 있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '마그나 카르타는 원래 63개 조항이었지만 현재 유효한 것은 단 3개뿐이에요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 인쇄와 출판
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '구텐베르크는 인쇄기 개발 비용을 갚지 못해 투자자에게 인쇄소를 빼앗겼어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '구텐베르크 성경 한 페이지에는 42줄이 들어가서 42행 성경이라고도 불러요',
  ),
  HistoryTip(category: 'GENERAL', fact: '구텐베르크가 사용한 활자 주조 기술은 원래 금세공에서 온 것이에요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '인쇄기 발명 후 50년 만에 유럽에서 600만 권 이상의 책이 인쇄됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '1500년까지 유럽에는 1,000개 이상의 인쇄소가 생겼어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '금속활자 인쇄술은 고려에서 1234년에 발명되어 구텐베르크보다 200년 앞섰어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '중국 송나라의 필승이 1040년경 세계 최초로 도자기 활자를 발명했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '15세기 베네치아는 유럽 인쇄 산업의 중심지로, 전체 책의 절반을 생산했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '이탤릭체는 더 많은 글자를 페이지에 넣어 책 크기를 줄이기 위해 개발됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '일본 최초의 인쇄물은 8세기 나라 시대에 만들어진 백만탑다라니예요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '무구정광대다라니경은 세계에서 현존하는 가장 오래된 목판 인쇄물이에요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '영국 최초의 인쇄업자 윌리엄 캑스턴은 1476년에 첫 책을 출판했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '마르틴 루터의 95개 논제는 인쇄술 덕분에 2주 만에 독일 전역에 퍼졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '1800년대 이전까지 인쇄공은 한 시간에 약 250장을 찍을 수 있었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '증기 인쇄기는 1814년 런던 타임스에서 처음 사용되어 생산량이 5배로 늘었어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 종이와 필기구
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '751년 탈라스 전투에서 포로로 잡힌 중국 장인들이 아랍에 제지술을 전했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '종이가 유럽에 전해지기 전까지 양피지 한 권을 만들려면 양 250마리가 필요했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '켈스의 서는 340장의 송아지 가죽을 사용해 만들어졌어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '파피루스는 강한 습기에 약해서 이집트 외의 기후에서는 잘 보존되지 않았어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '고대 로마에서는 밀랍을 바른 나무판에 철필로 글을 썼어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '중세 유럽에서 좋은 품질의 잉크를 만들려면 철, 아교, 포도주가 필요했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '거위 깃털펜은 왼쪽 날개 깃털이 오른손잡이에게 더 편했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '금속 펜촉은 1822년에 발명됐지만 대량 생산은 1830년대에야 가능해졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '만년필의 모세관 현상을 이용한 잉크 공급 시스템은 1884년에 완성됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '지우개 달린 연필은 1858년에 미국에서 특허를 받았어요'),
  HistoryTip(category: 'GENERAL', fact: '볼펜을 발명한 비로 형제는 원래 신문기자와 화학자였어요'),
  HistoryTip(category: 'GENERAL', fact: '볼펜이 처음 미국에서 팔렸을 때 가격은 12달러 50센트였어요'),
  HistoryTip(category: 'GENERAL', fact: '형광펜은 1963년 일본에서 처음 개발됐어요'),
  HistoryTip(category: 'GENERAL', fact: '포스트잇은 접착력이 너무 약한 실패작에서 우연히 탄생했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '화이트는 1951년 비서가 물감으로 오타를 지우던 것에서 시작됐어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 시간과 달력
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '해시계는 기원전 3500년경 이집트에서 처음 사용됐어요'),
  HistoryTip(category: 'GENERAL', fact: '물시계는 흐린 날과 밤에도 시간을 잴 수 있게 해줬어요'),
  HistoryTip(category: 'GENERAL', fact: '인도 자이푸르의 해시계는 높이가 27m로 세계에서 가장 커요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '기계식 시계는 13세기 유럽 수도원에서 예배 시간을 알리기 위해 발명됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '시계에 분침이 추가된 것은 17세기 후반이에요'),
  HistoryTip(category: 'GENERAL', fact: '초침이 달린 시계는 18세기에야 일반화됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '로마인들이 기원전 264년 시칠리아에서 가져온 해시계는 100년간 시간이 맞지 않았어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '줄리어스 시저가 만든 율리우스력은 1582년까지 1,600년 이상 사용됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '그레고리력으로 바꿀 때 1582년 10월에서 10일이 사라졌어요'),
  HistoryTip(category: 'GENERAL', fact: '영국은 그레고리력을 170년이나 늦게 1752년에야 채택했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '러시아는 1918년에야 그레고리력을 채택해서 10월 혁명이 실제로는 11월에 일어났어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '마야인들은 태양력, 의식력 등 여러 달력을 동시에 사용했어요'),
  HistoryTip(category: 'GENERAL', fact: '일주일이 7일인 것은 고대 바빌로니아에서 유래했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '프랑스 혁명 때 10진법 시간과 10일 주를 도입했지만 곧 폐지됐어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '표준시가 도입되기 전에는 각 도시마다 태양 위치에 따른 고유한 시간을 사용했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '철도의 등장으로 1840년대에 영국에서 처음 표준시가 필요해졌어요'),
  HistoryTip(category: 'GENERAL', fact: '국제 표준시 체계는 1884년 워싱턴 회의에서 결정됐어요'),

  // ============================================================
  // 추가 역사적 상식 - 암호와 비밀 통신
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '줄리어스 시저는 알파벳을 3글자씩 밀어서 암호를 만들었어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '에니그마 암호기를 해독한 것이 2차 세계대전을 2년 단축시켰다고 해요',
  ),
  HistoryTip(category: 'GENERAL', fact: '폴란드 수학자들이 영국보다 먼저 1932년에 에니그마를 해독했어요'),
  HistoryTip(category: 'GENERAL', fact: '앨런 튜링이 만든 에니그마 해독기 이름은 봄브였어요'),
  HistoryTip(category: 'GENERAL', fact: '나바호 원주민 언어가 2차 세계대전 때 미군의 암호로 사용됐어요'),
  HistoryTip(category: 'GENERAL', fact: '일본군은 끝까지 나바호 암호를 해독하지 못했어요'),
  HistoryTip(category: 'GENERAL', fact: '중세 유럽에서는 레몬즙으로 보이지 않는 잉크를 만들었어요'),
  HistoryTip(category: 'GENERAL', fact: '메리 여왕은 암호 편지가 해독되면서 반역죄로 처형됐어요'),
  HistoryTip(category: 'GENERAL', fact: '비제네르 암호는 300년간 해독 불가능한 것으로 여겨졌어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1차 세계대전 때 독일의 치머만 전보가 해독되어 미국의 참전을 이끌었어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 통신의 역사
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '봉화는 고대 그리스부터 사용됐으며, 중국 만리장성에서도 활용됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '깃발 신호로 통신하는 수기 신호법은 18세기 프랑스에서 체계화됐어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '1794년 프랑스의 샤프 형제가 시각 전신망을 만들어 556km를 연결했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '모스 부호의 점과 선은 가장 자주 쓰는 글자일수록 짧게 만들어졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '1844년 모스가 보낸 첫 전신 메시지는 하나님이 하신 일을 보라였어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '대서양 횡단 해저 전신 케이블은 1858년에 처음 설치됐지만 3주 만에 고장났어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '1866년에야 대서양 횡단 전신이 안정적으로 작동했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '벨의 첫 전화 통화 내용은 왓슨 씨, 이리 와요. 당신이 필요해요였어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '벨은 전화 특허를 받은 같은 날 다른 발명가 그레이도 출원했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '전화는 발명 당시 전보를 완전히 대체할 것으로 예상됐지만 수십 년간 공존했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '전화 교환원은 초기에 소년들이었지만 불친절해서 곧 여성들로 교체됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '1915년에 처음으로 미국 대륙 횡단 전화 통화가 이루어졌어요'),
  HistoryTip(category: 'GENERAL', fact: '세계 최초의 전화번호부는 1878년 미국 코네티컷에서 발행됐어요'),
  HistoryTip(category: 'GENERAL', fact: '비상전화 번호 911은 1968년 미국에서 처음 도입됐어요'),

  // ============================================================
  // 추가 역사적 상식 - 중세와 르네상스
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '중세 유럽에서 책 한 권의 가격은 농부의 1년 수입과 맞먹었어요'),
  HistoryTip(category: 'GENERAL', fact: '중세 수도사들은 필사실에서 하루 6시간씩 책을 베껴썼어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '중세 필사본의 여백에는 수도사들이 그린 우스꽝스러운 낙서가 많이 남아있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '11~12세기 독일 수녀원에서 여성 필사사들이 활동한 증거가 발견됐어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '수녀의 치아에서 푸른 안료가 발견되어 그녀가 채색 필사사였음이 밝혀졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '베리 공작의 매우 호화로운 시도서는 세계에서 가장 유명한 중세 필사본이에요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '켈스의 서는 아일랜드의 수도사들이 바이킹을 피해 이동하며 만들었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '중세 대학에서는 학생들이 강의를 받아쓰고 그것을 베껴서 책을 만들었어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '르네상스 시대 이탈리아에서는 필사본 수집이 부의 상징이었어요'),
  HistoryTip(category: 'GENERAL', fact: '페트라르카는 잃어버린 고대 문헌을 찾아 유럽 전역을 여행했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '단테의 신곡은 라틴어가 아닌 이탈리아어로 쓰여 문학 혁명을 일으켰어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '마키아벨리의 군주론은 출판 당시 금서로 지정됐어요'),
  HistoryTip(category: 'GENERAL', fact: '코페르니쿠스의 지동설 책은 그가 죽은 해인 1543년에 출판됐어요'),
  HistoryTip(category: 'GENERAL', fact: '갈릴레이는 지동설을 지지했다가 종교재판에서 유죄 판결을 받았어요'),
  HistoryTip(category: 'GENERAL', fact: '1500년까지 유럽에서 출판된 책들을 인쿠나불라라고 불러요'),

  // ============================================================
  // 추가 역사적 상식 - 동아시아
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '일본의 히라가나와 가타카나는 한자를 간략화해서 9세기경에 만들어졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '중국 한자는 약 5만 자가 넘지만 일상에서는 3,000~4,000자면 충분해요',
  ),
  HistoryTip(category: 'GENERAL', fact: '한자 사전에 등재된 가장 복잡한 글자는 획이 64획이에요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1297년 중국 관료 왕정이 6만 개 이상의 나무 활자를 만들었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '일본 최초의 신문은 1871년에 창간된 요코하마 마이니치 신문이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '조선시대에는 책을 빌려주는 세책점이 성행했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '연행사는 중국에서 새 책을 구해오는 것이 중요한 임무 중 하나였어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '일본에서는 에도 시대에 대여점에서 책을 빌려 읽는 문화가 발달했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '중국 명나라 영락대전은 세계 최대 규모의 백과사전으로 1만 권이 넘었어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '베트남은 한자에서 파생된 쯔놈 문자를 15세기부터 사용했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '몽골 제국은 파스파 문자를 공용 문자로 만들었지만 널리 퍼지지 않았어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '티베트 문자는 7세기에 인도 문자를 바탕으로 만들어졌어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '일본 만화는 12세기 두루마리 그림 조주기가에서 유래를 찾기도 해요',
  ),
  HistoryTip(category: 'GENERAL', fact: '중국에서 먹은 3000년 이상의 역사를 가지고 있어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '붓은 기원전 3세기 중국 진나라 때 몽염 장군이 개량했다고 전해져요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 우편과 배달
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '페르시아 제국의 왕립 도로에서는 역마 체계로 하루에 290km를 이동했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '로마 제국의 쿠르수스 푸블리쿠스는 국가 우편 시스템의 시초였어요'),
  HistoryTip(category: 'GENERAL', fact: '세계 최초의 우표 페니 블랙은 1840년 영국에서 발행됐어요'),
  HistoryTip(category: 'GENERAL', fact: '우표 발명 전에는 받는 사람이 우편 요금을 지불했어요'),
  HistoryTip(category: 'GENERAL', fact: '전서구는 고대 이집트에서부터 메시지 전달에 사용됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '1차 세계대전 때 전서구 셰르 아미는 다리가 부러진 채로 메시지를 전달해 198명을 구했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '2차 세계대전 때 승리 우편 V-Mail은 편지를 마이크로필름으로 만들어 운송했어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '미국 포니 익스프레스는 2,000km를 10일 만에 주파했지만 18개월 만에 문을 닫았어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '우편번호 시스템은 1963년 미국에서 처음 도입됐어요'),
  HistoryTip(category: 'GENERAL', fact: '영국의 우체통은 빨간색이지만, 원래는 초록색이었어요'),
  HistoryTip(category: 'GENERAL', fact: '우편엽서는 1869년 오스트리아에서 처음 등장했어요'),
  HistoryTip(category: 'GENERAL', fact: '성탄절 카드를 보내는 관습은 1843년 영국에서 시작됐어요'),

  // ============================================================
  // 추가 역사적 상식 - 유명한 문서들
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '미국 독립선언서의 주요 작성자가 토마스 제퍼슨인 것은 1790년대에야 알려졌어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '미국 헌법 원본은 양피지에 쓰여져 있어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '링컨의 게티즈버그 연설문은 272단어로 단 2분밖에 걸리지 않았어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '나폴레옹의 민법전은 현재도 많은 나라의 법체계에 영향을 미치고 있어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '함무라비 법전은 기원전 1754년에 만들어진 현존하는 가장 오래된 성문법이에요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '돔즈데이 북은 1086년 영국 전국 토지 조사 결과를 기록한 문서예요',
  ),
  HistoryTip(category: 'GENERAL', fact: '앤 프랭크의 일기는 그녀의 아버지가 사후에 편집해서 출판했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '카를 마르크스의 자본론은 그가 영국 대영박물관 도서관에서 집필했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '다윈의 종의 기원은 출판 첫날 1,250부가 모두 팔렸어요'),
  HistoryTip(category: 'GENERAL', fact: '아인슈타인의 상대성 이론 논문은 불과 31페이지였어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '마르코 폴로의 동방견문록은 그가 감옥에서 동료 수감자에게 구술해 썼어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '베오울프는 영어로 쓰인 가장 오래된 서사시로 1,000년 이상 된 필사본이 남아있어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 발명과 기술
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '증기기관을 발명한 와트는 증기기관차를 달가워하지 않았어요'),
  HistoryTip(category: 'GENERAL', fact: '화약은 중국 연금술사들이 불로장생약을 찾다가 우연히 발견했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '나침반은 중국에서 점술 도구로 먼저 사용되다가 항해에 쓰이게 됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '안경은 13세기 이탈리아에서 발명됐어요'),
  HistoryTip(category: 'GENERAL', fact: '망원경은 1608년 네덜란드의 안경 제작자가 발명했어요'),
  HistoryTip(category: 'GENERAL', fact: '현미경은 망원경보다 몇 년 늦은 1620년대에 발명됐어요'),
  HistoryTip(category: 'GENERAL', fact: '온도계는 1714년 파렌하이트가 수은을 사용해 발명했어요'),
  HistoryTip(category: 'GENERAL', fact: '피뢰침은 벤저민 프랭클린이 1752년 연 실험 후 발명했어요'),
  HistoryTip(category: 'GENERAL', fact: '배터리는 1800년 이탈리아의 볼타가 발명했어요'),
  HistoryTip(category: 'GENERAL', fact: '사진술은 1839년 다게르가 공개해서 다게레오타입이라고 불렸어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '엘리베이터 안전장치는 1853년 오티스가 발명해서 고층 건물이 가능해졌어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '다이너마이트를 발명한 노벨은 자신의 발명이 전쟁에 쓰일까 봐 노벨상을 만들었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '라디오는 마르코니가 1901년 대서양 횡단 무선 통신에 성공하며 대중화됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '텔레비전이란 이름은 그리스어 멀리와 라틴어 보다의 합성어예요'),
  HistoryTip(category: 'GENERAL', fact: '컬러 텔레비전 방송은 1954년 미국에서 처음 시작됐어요'),

  // ============================================================
  // 추가 역사적 상식 - 언어와 번역
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '성경은 세계에서 가장 많은 언어로 번역된 책이에요'),
  HistoryTip(category: 'GENERAL', fact: '돈키호테는 성경 다음으로 많이 번역된 소설이에요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '에스페란토는 1887년에 만들어진 국제 공용어를 목표로 한 인공어예요',
  ),
  HistoryTip(category: 'GENERAL', fact: '옥스퍼드 영어사전의 첫 판은 완성하는 데 70년이 걸렸어요'),
  HistoryTip(category: 'GENERAL', fact: '옥스퍼드 영어사전에는 60만 개 이상의 단어가 수록되어 있어요'),
  HistoryTip(category: 'GENERAL', fact: '사무엘 존슨은 9년 동안 혼자서 최초의 영어사전을 편찬했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '노아 웹스터의 미국 영어사전은 영국 영어와 다른 미국식 철자법을 정립했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '최초의 한글 사전은 1920년 조선총독부에서 발행됐어요'),
  HistoryTip(category: 'GENERAL', fact: '현재 전 세계에서 약 7,000개의 언어가 사용되고 있어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '언어의 약 40%가 사용자 1,000명 미만으로 소멸 위기에 있어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '라틴어는 중세까지 유럽 학문과 종교의 공용어였어요'),
  HistoryTip(category: 'GENERAL', fact: '아랍어는 오른쪽에서 왼쪽으로 쓰는 대표적인 언어예요'),
  HistoryTip(category: 'GENERAL', fact: '중국어 보통화는 세계에서 가장 많은 모국어 사용자를 가진 언어예요'),

  // ============================================================
  // 추가 역사적 상식 - 교육과 학교
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '세계에서 가장 오래된 대학은 859년에 설립된 모로코의 카라윈 대학이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '볼로냐 대학은 1088년에 설립된 유럽에서 가장 오래된 대학이에요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '옥스퍼드 대학은 1096년부터 수업이 시작돼 영어권 최고 대학이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '하버드 대학은 1636년에 설립되어 미국에서 가장 오래됐어요'),
  HistoryTip(category: 'GENERAL', fact: '중세 대학 학생들은 라틴어로만 수업을 듣고 토론했어요'),
  HistoryTip(category: 'GENERAL', fact: '최초의 의무 교육 제도는 1763년 프로이센에서 시작됐어요'),
  HistoryTip(category: 'GENERAL', fact: '칠판은 1801년 스코틀랜드의 한 학교에서 처음 사용됐어요'),
  HistoryTip(category: 'GENERAL', fact: '연필심 등급 시스템 HB, 2B 등은 19세기 초에 표준화됐어요'),
  HistoryTip(category: 'GENERAL', fact: '공교육에서 타자기 수업이 도입된 것은 1920년대부터예요'),
  HistoryTip(category: 'GENERAL', fact: '객관식 시험은 1914년 미국 캔자스 대학에서 처음 도입됐어요'),

  // ============================================================
  // 추가 역사적 상식 - 신문과 저널리즘
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '세계 최초의 인쇄 신문은 1605년 독일 스트라스부르에서 발행됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '런던 타임스는 1785년에 창간되어 현재까지 이어지고 있어요'),
  HistoryTip(category: 'GENERAL', fact: '뉴욕 타임스의 모토는 인쇄하기에 적합한 모든 뉴스예요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '황색 저널리즘이라는 말은 1890년대 뉴욕 신문 전쟁에서 유래했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '퓰리처상은 황색 저널리즘의 창시자인 퓰리처의 유산으로 만들어졌어요'),
  HistoryTip(category: 'GENERAL', fact: '워터게이트 사건은 워싱턴 포스트 기자들의 탐사 보도로 밝혀졌어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '일본 최초의 일간지는 1870년에 창간된 요코하마 마이니치 신문이에요',
  ),
  HistoryTip(category: 'GENERAL', fact: '한국 최초의 근대 신문은 1883년에 창간된 한성순보예요'),
  HistoryTip(category: 'GENERAL', fact: '크로스워드 퍼즐은 1913년 뉴욕 월드 신문에 처음 실렸어요'),
  HistoryTip(category: 'GENERAL', fact: '만화 연재물은 1895년 뉴욕 월드 신문에서 시작됐어요'),

  // ============================================================
  // 추가 역사적 상식 - 기록과 통계
  // ============================================================
  HistoryTip(
    category: 'GENERAL',
    fact: '기네스북은 1955년 맥주 회사 기네스의 펍 논쟁 해결용으로 시작됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '인구 조사는 고대 로마에서 세금과 군대 징집을 위해 실시됐어요'),
  HistoryTip(category: 'GENERAL', fact: '근대 인구 조사의 시초는 1790년 미국에서 시작됐어요'),
  HistoryTip(category: 'GENERAL', fact: '천문 관측 기록은 고대 바빌로니아에서 3,000년 이상 유지됐어요'),
  HistoryTip(category: 'GENERAL', fact: '중국의 사관 제도는 역사 기록을 위해 수천 년간 유지됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '기상 관측 기록은 1659년 영국에서 시작되어 현재까지 이어지고 있어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '지진 기록은 중국 후한 시대 132년에 만든 지동의로 시작됐어요'),
  HistoryTip(category: 'GENERAL', fact: '올림픽 기록은 기원전 776년 첫 대회부터 문서로 남아있어요'),

  // ============================================================
  // 추가 역사적 상식 - 현대 기술
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '팩스 기술은 전화보다 30년이나 먼저 1843년에 발명됐어요'),
  HistoryTip(category: 'GENERAL', fact: '복사기를 발명한 체스터 칼슨은 20개 넘는 회사에서 거절당했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '바코드는 1952년에 특허를 받았지만 1974년에야 처음 상용화됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: 'QR코드는 1994년 일본 자동차 부품 회사에서 발명됐어요'),
  HistoryTip(category: 'GENERAL', fact: '최초의 휴대폰 통화는 1973년 모토로라의 마틴 쿠퍼가 했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '최초의 스마트폰은 1992년 IBM 사이먼으로, 터치스크린과 앱이 있었어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '첫 번째 웹사이트는 1991년 CERN에서 팀 버너스 리가 만들었어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '이모티콘 :-)은 1982년 카네기 멜런 대학에서 처음 제안됐어요'),
  HistoryTip(category: 'GENERAL', fact: '이모지는 1999년 일본 휴대폰 회사에서 처음 만들어졌어요'),
  HistoryTip(category: 'GENERAL', fact: '해시태그 #는 2007년 트위터 사용자가 제안해서 퍼졌어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: 'CAPTCHA는 Completely Automated Public Turing test의 약자예요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: 'USB 포트는 어느 방향으로 꽂아도 맞도록 설계됐지만 실패해서 USB-C가 나왔어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 흥미로운 사실들
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '셰익스피어는 1,700개 이상의 새로운 영어 단어를 만들었어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '제인 오스틴의 소설들은 그녀가 살아있을 때 모두 익명으로 출판됐어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '에드거 앨런 포는 탐정 소설이라는 장르를 발명한 것으로 평가받아요'),
  HistoryTip(category: 'GENERAL', fact: '해리 포터 첫 편은 12개 출판사에서 거절당했어요'),
  HistoryTip(category: 'GENERAL', fact: '반지의 제왕은 톨킨이 12년에 걸쳐 집필했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '레 미제라블의 원고는 휴고가 직접 쓴 것으로 1,900페이지가 넘어요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '가장 긴 소설은 마르셀 프루스트의 잃어버린 시간을 찾아서로 약 960만 글자예요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '아가사 크리스티는 66편의 추리 소설을 써서 베스트셀러 작가 1위예요',
  ),
  HistoryTip(category: 'GENERAL', fact: '어린 왕자는 250개 이상의 언어로 번역된 세계적 베스트셀러예요'),
  HistoryTip(category: 'GENERAL', fact: '1984와 멋진 신세계는 디스토피아 소설의 양대 산맥이에요'),
  HistoryTip(category: 'GENERAL', fact: '프란츠 카프카는 유언으로 자신의 원고를 모두 불태워 달라고 했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '헤르만 멜빌의 모비딕은 출판 당시 혹평을 받았지만 지금은 명작으로 평가돼요',
  ),
  HistoryTip(category: 'GENERAL', fact: '파우스트를 쓴 괴테는 60년에 걸쳐 작품을 완성했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '빅토르 위고는 레 미제라블의 판매량을 묻는 편지에 ?만 썼고, 출판사는 !로 답했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '톨스토이는 전쟁과 평화를 7년에 걸쳐 쓰면서 수십 번 수정했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '도스토옙스키는 도박 빚을 갚기 위해 노름꾼을 단 26일 만에 완성했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '오스카 와일드는 감옥에서 긴 편지 형식의 글 깊은 곳에서를 썼어요'),
  HistoryTip(category: 'GENERAL', fact: '어니스트 헤밍웨이는 매일 서서 글을 썼어요'),
  HistoryTip(category: 'GENERAL', fact: '마크 트웨인은 타자기로 원고를 제출한 최초의 작가로 알려져 있어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '버지니아 울프는 서재가 따로 없어서 집 거실에 놓인 책상에서 글을 썼어요',
  ),

  // ============================================================
  // 추가 역사적 상식 - 기타 흥미로운 사실들
  // ============================================================
  HistoryTip(category: 'GENERAL', fact: '고대 이집트에서는 고양이를 죽이면 사형에 처해졌어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '클레오파트라는 피라미드가 지어진 시기보다 아이폰 발명 시기에 더 가까워요',
  ),
  HistoryTip(
    category: 'GENERAL',
    fact: '티라노사우루스와 스테고사우루스의 시간 차이는 티라노사우루스와 인간보다 커요',
  ),
  HistoryTip(category: 'GENERAL', fact: '옥스퍼드 대학은 아즈텍 제국보다 더 오래됐어요'),
  HistoryTip(category: 'GENERAL', fact: '팩스가 발명됐을 때 미국은 아직 노예제가 있었어요'),
  HistoryTip(category: 'GENERAL', fact: '닌텐도는 오스만 제국이 아직 존재할 때 설립됐어요'),
  HistoryTip(category: 'GENERAL', fact: '매머드는 이집트에서 피라미드를 지을 때까지 살아있었어요'),
  HistoryTip(category: 'GENERAL', fact: '하버드 대학이 설립됐을 때는 아직 미적분학이 발명되지 않았어요'),
  HistoryTip(category: 'GENERAL', fact: '찰리 채플린과 아돌프 히틀러는 같은 해 1889년에 태어났어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '앤 프랭크와 마틴 루터 킹 주니어는 같은 해 1929년에 태어났어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '마지막 공개 참수형이 프랑스에서 집행된 해에 스타워즈가 개봉했어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '코카콜라가 발명됐을 때 빈센트 반 고흐는 아직 화가로 활동 중이었어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '체스가 발명된 지 1,500년이 넘었어요'),
  HistoryTip(category: 'GENERAL', fact: '주사위 게임은 5,000년 이상의 역사를 가지고 있어요'),
  HistoryTip(category: 'GENERAL', fact: '카드 게임은 9세기 중국에서 시작됐어요'),
  HistoryTip(category: 'GENERAL', fact: '가위바위보의 기원은 중국 한나라 시대로 거슬러 올라가요'),
  HistoryTip(category: 'GENERAL', fact: '피자는 원래 가난한 사람들의 음식이었어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '토마토는 유럽에 처음 소개됐을 때 200년간 독이 있다고 여겨졌어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '감자는 유럽에서 처음에 관상용 식물로 재배됐어요'),
  HistoryTip(category: 'GENERAL', fact: '초콜릿은 원래 쓴 음료로 마야와 아즈텍 귀족들이 마셨어요'),
  HistoryTip(category: 'GENERAL', fact: '아이스크림은 마르코 폴로가 중국에서 가져왔다는 전설이 있어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '포크는 중세 유럽에서 악마의 도구로 여겨져 사용이 금지되기도 했어요',
  ),
  HistoryTip(category: 'GENERAL', fact: '지폐는 중국 당나라에서 처음 사용됐어요'),
  HistoryTip(category: 'GENERAL', fact: '신용카드는 1950년 다이너스 클럽 카드가 최초예요'),
  HistoryTip(category: 'GENERAL', fact: 'ATM 기계는 1967년 영국 런던에서 처음 설치됐어요'),
  HistoryTip(
    category: 'GENERAL',
    fact: '비트코인 백서는 2008년에 사토시 나카모토라는 익명으로 발표됐어요',
  ),
];
