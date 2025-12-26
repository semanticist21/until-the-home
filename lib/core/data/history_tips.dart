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
];
