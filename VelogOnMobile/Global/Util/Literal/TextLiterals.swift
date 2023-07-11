//
//  TextLiterals.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/29.
//

import UIKit

enum TextLiterals {
    
    static let noneText: String = ""
    
    // MARK: - Home
    
    static let homeViewControllerHeadTitle: String = "Home"
    
    // MARK: - storage
    
    static let deleteButtonTitle: String = "Edit"
    static let doneButtonTitle: String = "Done"
    static let headViewTitle: String = "Storage"
    
    // MARK: - tab Bar
    
    static let homeViewControllerTitle: String = "홈"
    static let listViewControllerTitle: String = "팔로우"
    static let storageViewControllerTitle: String = "스크랩"
    static let settingViewControllerTitle: String = "설정"
    
    // MARK: - tag search
    
    static let myTag: String = "내 태그"
    static let popularTag = "인기 태그"
    static let addTagSuccessText: String = "키워드가 추가되었습니다."
    static let addTagRequestErrText: String = "이미 추가된 관심 키워드입니다."
    static let tagTitleLabelText: String = "Add Keyword"
    static let tagSearchPlaceholderText: String = "태그를 추가해보세요."
    static let deleteAll = "모두 지우기"
    static let deleteTagSuccess = "태그가 삭제되었습니다."
    static let deleteTagActionSheetTitle: String = "태그 삭제"
    static let deleteTagActionSheetMessage: String = "정말 태그를 삭제하시겠습니까?"
    static let delete: String = "삭제"
    static let cancel: String = "취소"
    
    // MARK: - subscriber search
    
    static let searchSubscriberIsNotValidText: String = "없는 팔로우입니다. 다시 검색해주세요."
    static let addSubsriberSuccessText: String = "구독자 추가되었습니다."
    static let addSubscriberRequestErrText: String = "이미 추가한 팔로우입니다. 다시 검색해주세요."
    static let subscriberSearchTitleLabelText: String = "Search Subscribers"
    static let subscriberSearchTextFieldPlaceholderText: String = "velog 아이디를 입력해주세요."
    
    // MARK: - button label
    
    static let addButtonText: String = "Add"
    static let dismissButtonText: String = "dismiss"
    
    // MARK: - posts tabMan
    
    static let postTabManTitleLabelText: String = "Posts"
    static let notifiButtonText: String = "Alarm"
    static let postTabManKeywordPostsTitleText: String = "Keyword Posts"
    static let postTabManSubscriberPostsTitleText: String = "Subscriber Posts"
    
    // MARK: - keyword posts
    
    static let addToastText: String = "추가되었습니다."
    static let alreadyAddToastText: String = "이미 스크랩한 글입니다."
    
    // MARK: - list
    
    static let listKeywordText: String = "Keywords"
    static let listSubscriberText: String = "Subscribers"
    static let listKeywordActionSheetTitleText: String = "Keyword"
    static let listSubscriberActionSheetTitleText: String = "Subscriber"
    static let listActionSheetCancelText: String = "Cancel"
    static let listAlertControllerTitleText: String = "추가"
    static let listAlertControllerMessageText: String = "추가할 기준을 선택해주세요."
    static let listTitleLabelText: String = "Follow"
    
    // MARK: - setting
    
    static let settingTitleLabelText: String = "Setting"
    static let settingAlertText: String = "구독 알림"
    static let settingSignOutText: String = "로그아웃"
    static let settingWithdrawalText: String = "회원탈퇴"
    static let settingChangeEmailText: String = "이메일 변경"
    static let settingChangePasswordText: String = "비밀번호 변경"
    
    // MARK: - table view
    
    static let tableViewDeleteSwipeTitle: String = "delete"
    
    // MARK: - navigation bar
    
    static let addSubscriberToastText:String = "팔로우 했습니다."
    static let deleteSubscriberToastText: String = "팔로우 취소 했습니다."
    static let navigationBarSubscribeButtonText: String = "팔로우"
    
    // MARK: - velog url
    
    static let velogBaseURL: String = "https://velog.io"
    
    // MARK: - scrap folder
    
    static let allPostsScrapFolderText: String = "모든 게시글"
    
    // MARK: - scrap PopUp view
    
    static let scrapPopUpViewLeftText: String = "스크랩했습니다."
    static let moveToScrapStorageButtonText: String = "보러가기"
    static let presentScrapFolderBottomSheetButtonText: String = "폴더에 담기"
    
    // MARK: - scrapFolderBottomSheet
    
    static let bottomSheetText: String = "폴더 선택"
    static let makeNewFolderButtonText: String = "새 폴더 만들기"
    static let newFolderAddTextFieldPlaceholder: String = "폴더명을 입력하세요."
    static let addFolderFinishedButtonTitleText: String = "완료"
    
    // MARK: - scrap storage view
    
    static let scrapStorageTitleLabel: String = "Scrap"
    static let addFolderAlertTitle: String = "폴더 추가"
    static let addFolderAlertOkActionTitle: String = "확인"
    static let addFolderAlertCancelActionTitle: String = "취소"
    static let alreadyHaveFolderToastText: String = "이미 존재하는 폴더명입니다."
    static let addFolderButtonTitle: String = "폴더 추가"
    static let postInFolderCountText: String = "개"
    
    // MARK: - storage view
    
    static let deleteFolderActionSheetTitle: String = "폴더 삭제"
    static let deleteFolderActionSheetMessage: String = "선택하신 폴더를 정말 삭제하시겠습니까?\n스크랩한 콘텐츠가 모두 삭제됩니다."
    static let deleteFolderActionSheetOkActionText: String = "삭제"
    static let deleteFolderActionSheetCancelActionText: String = "취소"
    
    static let folderNameChangeSuccessToastText: String = "폴더명이 변경되었습니다."
    static let folderNameChangeToastTitle: String = "폴더 이름 변경"
    static let folderNameChangeToastOkActionText: String = "확인"
    static let folderNameChangeToastCancelActionText: String = "취소"
    
    static let storageViewDeleteFolderButtonText: String = "폴더 삭제"
    static let storageViewChangeFolderNameButtonText: String = "이름 변경"
    
    static let storageViewPostDeleteButtonText: String = "삭제"
    
    // MARK: - post search view
    
    static let postSearchViewRecentLabel: String = "최근 검색어"
    static let postSearchViewDeleteAllRecentDataButtonText: String = "모두 지우기"
    static let postSearchViewTrendLabel: String = "인기 키워드"
    
    static let postSearchViewSearchBarPlaceholderText: String = "통합검색"
    
    // MARK: - subscriber list view
    
    static let unSubscriberAlertTitle: String = "팔로우 취소"
    static let unSubscriberAlertMessage: String = "정말 팔로우를 취소하시겠습니까?"
    static let unSubscriberAlertOkActionText: String = "네"
    static let unSubscriberAlertCancelActionText: String = "아니요"
    
    static let subscriberListViewSubTitleLabel: String = "팔로우 중인 사람"
    static let subscriberListViewUnSubscribeButtonText: String = "팔로우 취소"
    
    // MARK: - search subscriber view
    
    static let searchSubscriberTitle: String = "팔로우 추가"
    
    // MARK: - setting view
    
    static let userInformationProcessingpPolicyText: String = "개인정보 처리방침"
    static let userInformationProcessingpPolicyWebUrl: String = "https://relieved-centaur-a76.notion.site/a45df2df95cf4df6a94309442b26e22d"
    static let provisionText: String = "이용약관"
    static let provisionWebUrl: String = "https://relieved-centaur-a76.notion.site/6173206801894b8da07833ef42c937d6"
    
    static let signOutAlertTitle: String = "로그아웃"
    static let signOutAlertMessage: String = "정말 로그아웃 하시겠습니까?"
    
    static let withdrawalAlertTitle: String = "회원탈퇴"
    static let withdrawalAlertMessage: String = "정말 회원탈퇴 하시겠습니까?\n복구하실 수 없습니다."
    
    static let settingAlertOkActionText: String = "네"
    static let settingAlertCancelActionText: String = "아니요"
    
    static let plolicyText: String = "개인정보 처리방침\n\n이지벨(이하 “회사”)는 회원이 이지벨 서비스(이하 “서비스”)에 저장한 개인정보의 보호를 중요하게 생각하고, 회원의 개인정보를 보호하기 위하여 항상 최선을 다해 노력하고 있습니다.본 개인정보처리방침은 2023년 7월 1일부터 효력을 가지며, 서비스가 수집하는 회원의 정보와 그 정보 수집 이유, 용도 및 회원의 콘텐츠를 처리하는 방법에 대한 설명입니다.\n\n1. 개인정보 수집항목 및 수집방법\n회사는 모든 회원에게 더 나은 서비스를 제공하기 위해 다음의 정보를 수집하고 저장합니다.\n① 회원이 제공하는 정보\n회원가입 시 가입에 필요한 정보를 아래와 같이 수집하고 있으며, 개인용 서비스와 기업용 서비스의 수집되는 항목은 아래와 같습니다.\n- 필수 : 없음\n- 선택 : 없음\n② 회원이 서비스를 사용할 때 수집하는 정보\n- 회원의 단말기(모바일, 컴퓨터) 정보, OS 종류 및 버전. 서비스 이용 기록, 국가, 언어, 프로그램 설치와 주요 기능 실행 등 사용량에 대한 기본 정보를 수집합니다.\n③ 서비스 이용 기록, 쿠키, 국가, 언어, 프로그램 설치와 주요 기능 실행 등 사용량에 대한 기본 정보를 수집합니다. 그 외에도 회원이 유료 서비스를 이용하는 과정에서 결제 등을 위하여 불가피하게 필요한 때에는 신용카드 정보 및 대금 청구 주소 등과 같이 결제에 필요한 거래 정보가 수집될 수 있습니다.\n④ 회원이 자신의 정보에 액세스하도록 허용하는 경우\n- 회원이 서비스에서 자신의 연락처에 액세스하도록 허용하는 경우, 서비스는 사용자가 차후 연락처를 이용할 수 있도록 서버에 연락처 정보를 저장합니다. 연락처 정보는 자료를 공유하거나 이메일을 보내거나 사람들에게 서비스에 초대하는 목적으로만 사용합니다.\n- 회원이 서비스에서 Google 또는 기타 서비스 제공업자의 회원 계정에 있는 정보에 액세스하도록 허용하는 경우, 서비스는 사용자가 차후 정보를 이용할 수 있도록 서비스 서버에 정보를 저장합니다.\n\n2. 개인정보 이용목적\n회사는 회원의 소중한 개인정보를 다음과 같은 목적으로만 이용하며, 목적이 변경될 경우에는 사전에 회원의 동의를 구하도록 하겠습니다.\n① 회원 가입 의사를 확인하고 계정을 생성하기 위하여 사용합니다.\n② 회원으로 가입한 이용자를 식별하고 불량회원의 부정 이용과 비인가 이용을 방지하기 위하여 사용합니다.\n③ 회원과 약속한 서비스를 제공하고 유료 서비스 구매 및 이용이 이루어지는 경우 이에 따른 요금 정산을 위해 사용됩니다.\n④ 서비스 내에서 회원 정보를 표시할 필요가 있는 경우(예: 공유된 문서의 작업자 정보 표시 등)에는 다른 회원에게 프로필 정보(예:이름, 사진 등)를 표시할 수 있습니다.\n⑤ 회원에게 다양한 서비스를 제공하고 서비스 이용 과정에서 회원의 문의사항이나 불만을 처리하고 공지사항 등을 전달하기 위해 사용합니다.\n⑥ 회사는 회원가입 시 동의한 회원에 한하여 제품 및 마케팅 정보를 제공할 수 있습니다. 신규 서비스 개발, 이벤트 등 프로모션 정보 전달 및 광고 게재 시에 해당 정보를 이용합니다. 회원은 서비스 계정 설정의 이벤트, 서비스 안내에서 수신을 거부할 수 있습니다.\n⑦ 맞춤형 서비스 제공 및 신규 서비스 개발 등에 참고하기 위하여 이를 익명화하여, 이용 패턴과 접속빈도 분석 및 서비스 이용에 대한 통계에서도 사용됩니다.\n\n3. 개인정보 제3자 제공\n회사는 회원들의 개인정보를 \"개인정보 이용목적\"에서 고지한 범위내에서 사용하며, 원칙적으로 이용자의 개인정보를 외부에 공개하지 않습니다. 다만, 아래의 경우에는 예외로 합니다.\n① 회원이 사전에 동의한 경우\n- 이러한 경우에도, 회사는 이용자에게 개인정보를 받는 자, 그의 이용목적, 제공되는 개인정보의 항목, 개인정보의 보유 및 이용 기간을 사전에 고지하고 이에 대해 명시적•개별적으로 동의를 얻습니다.\n② 관련 법령에 특별한 규정이 있는 경우\n\n4. 개인정보 정정 및 회원탈퇴\n① 회원은 언제든지 등록된 회원의 개인정보를 열람하거나 정정할 수 있습니다.\n② 회원은 개인정보 수집 및 활용 관련 절과 조항에 명시된 바와 같이 회원가입 등을 통해 개인정보의 수집, 이용, 제공에 대해 동의한 내용을 언제든지 철회할 수 있습니다. 아래에 기재된 연락처의 개인정보관리책임자에게 서면, 전화, 이메일 등으로 연락하시면 바로 회원탈퇴를 위해 필요한 조치를 합니다. 동의 철회를 하고 개인정보를 파기하는 등의 조치를 한 경우에는 그 사실을 회원에게 지체 없이 통지하도록 하겠습니다.\n\n5. 개인정보 보유기간 및 이용기간\n회사는 이용자의 개인정보를 회원가입을 하는 시점부터 서비스를 제공하는 기간에만 제한적으로 이용하고 있습니다. 이용자가 (i) 회원탈퇴를 요청하거나 제공한 개인정보의 수집 및 이용에 대한 동의를 철회하는 경우, (ii) 수집 및 이용목적이 달성된 경우, (iii) 보유 및 이용기간이 종료된 경우 해당 이용자의 개인정보는 지체 없이 파기 됩니다.\n\n6. 개인정보 삭제 절차 및 방법\n이용자의 개인정보는 원칙적으로 개인정보의 수집 및 이용목적이 달성되면 지체 없이 삭제됩니다.\n회사의 개인정보 삭제 절차 및 방법은 다음과 같습니다.\n① 파기절차\nA. 이용자가 회원가입 등을 위해 입력한 정보는 목적이 달성된 후 별도의 DB로 옮겨져(종이의 경우 별도의 서류함) 회사 방침 및 기타 관련 법령에 의한 정보보호 사유에 따라(보유 및 이용기간 참조) 일정 기간 저장된 후 삭제됩니다.\nB. 동 개인정보는 관련 법령에 의해 요구되는 경우 외에는 보유되는 이외의 다른 목적으로 이용되지 않습니다.\n② 파기방법\nA. 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각을 통하여 파기합니다.\nB. 전자적 파일 형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.\n③ 전자상거래 등에서의 소비자 보호에 관한 법률, 전자금융거래법, 통신비밀보호법 등 법령에서 일정기간 정보의 보관을 규정하는 경우는 아래와 같습니다. 회사는 이 기간 동안 법령의 규정에 따라 개인정보를 보관하며, 본 정보를 다른 목적으로는 절대 이용하지 않습니다.\nA. 전자상거래 등에서 소비자 보호에 관한 법률\n- 계약 또는 청약철회 등에 관한 기록: 5년 보관\n- 대금결제 및 재화 등의 공급에 관한 기록: 5년 보관\n- 소비자의 불만 또는 분쟁처리에 관한 기록: 3년 보관\nB. 전자금융거래법\n- 전자금융에 관한 기록: 5년 보관\nC. 통신비밀보호법\n- 로그인 기록: 3개월\n\n7. 개인정보의 국외 이전에 관한 사항\n본 서비스는 개인정보의 안전한 보관을 위해 아래와 같이 개인정보를 보관하고 있으며, 개인정보 보관 사업자는 본 서비스의 개인정보에 접근할 수 없습니다. 또한 보관된 개인정보는 ‘5. 개인정보 보유기간 및 이용기간’, ‘6. 개인정보 삭제 절차 및 방법’에 따라 관리 및 삭제 됩니다.\n- 보관되는 개인정보 항목:\n1. 개인용 서비스: 이메일, 기기 모델명, 이름\n- 개인정보 보관 국가: 미국\n- 개인정보 보관 법인명 및 연락처: Google Inc./support.google.com\n\n8. 개인정보처리방침 변경\n회사는 관련 법률이나 서비스의 변경사항을 반영하기 위한 목적 등으로 개인정보처리방침을 수정할 수 있습니다. 현 개인정보처리방침 내용 추가, 삭제 및 수정이 있을 시에는 개정 최소 7일 전부터 홈페이지의 '공지사항' 또는 이메일 통해 알릴 것입니다. 다만, 개인정보의 수집 및 활용, 제3자 제공 등과 같이 이용자 권리의 중요한 변경이 있을 때는 최소 30일 전에 알립니다.\n\n9. 보안\n회사는 보유하는 정보에 대한 무단 액세스, 변경, 공개 또는 삭제로부터 서비스 및 서비스 사용자를 보호하기 위해 노력합니다.\n서비스상의 사용자 데이터에 액세스하려면 비밀번호가 필요하며 유료 결제 시 입력한 민감한 데이터(신용카드 정보 등)는 SSL 암호화로 보호됩니다.\n그러나 유선 또는 무선 인터넷은 100% 안전한 환경이 아니므로 귀하가 당사에 전송한 정보의 안전성을 보장할 수 없습니다. 따라서 회사에 의해 구현된 보안 절차에도 불구하고 당사의 물리적, 기술적 또는 경영상의 안전장치 중 어느 하나의 파괴 또는 침해로 인해 정보가 액세스, 공개, 변경 또는 파괴될 가능성이 없다고 보장하지 않습니다\n\n10. 추적 금지\n회사는 맞춤형 광고를 제공하기 위한 목적으로 고객을 일정 기간 및 제3자 웹 사이트에 걸쳐 추적하지 않으며, 이에 따라 추적 금지(DNT) 신호에 응답하지 않습니다.\n\n11. 이용자 및 법정대리인의 권리와 그 행사방법\n회원 및 법정 대리인은 언제든지 등록되어 있는 자신 혹은 당해 만 14세 미만 아동의 개인정보를 조회하거나 수정할 수 있으며, 회사의 개인정보의 처리에 동의하지 않는 경우 동의를 거부하거나 가입해지(회원탈퇴)를 요청하실 수 있습니다. 다만, 그러한 경우 서비스의 일부 또는 전부 이용이 어려울 수 있습니다.\n혹은 개인정보관리책임자에게 서면, 전화 또는 이메일로 연락하시면 지체 없이 조치하겠습니다.\n회원이 개인정보의 오류에 대한 정정을 요청하신 경우에는 정정을 완료하기 전까지 당해 개인정보를 이용 또는 제공하지 않습니다. 또한 잘못된 개인정보를 제3 자에게 이미 제공한 경우에는 정정 처리결과를 제3자에게 지체 없이 통지하여 정정이 이루어지도록 하겠습니다.\n회사는 회원 혹은 법정 대리인의 요청에 의해 해지 또는 삭제된 개인정보는 \"5. 개인정보의 보유 및 이용기간\"에 명시된 바에 따라 처리하고 그 외의 용도로 열람 또는 이용할 수 없도록 처리하고 있습니다.\n\n12. 개인정보에 관한 민원서비스\n개인정보 보호에 관한 질문이나 문의가 있는 경우 또는 고객 지원이 필요한 경우 아래에 기재된 연락처로 문의해 주시기 바랍니다.\n\n▶ 개인정보보호책임자\n\n- 성명 : 홍준혁\n- 직위 : Team Leader\n- 연락처 : junhyeok2166@daum.net\n\n귀하께서는 회사의 서비스를 이용하시며 발생하는 모든 개인정보보호 관련 민원을 개인정보관리책임자 혹은 담당 부서로 신고하실 수 있습니다. 회사는 이용자들의 신고사항에 대해 신속하게 충분한 답변을 드릴 것입니다\n\n공고 일자: 2023년 07월 01일\n시행 일자: 2023년 07월 01일\n\n부칙\n\n본 개인정보처리방침은 각 국가별로 법률의 요구사항에 따라 언어별로 상이할 수 있습니다. 각 언어별 개인정보처리방침의 내용이 서로 충돌하는 경우에는 그 지역의 언어로 작성된 개인정보처리방침이 우선 적용되며, 그 지역의 언어로 작성된 개인정보처리방침이 없을 경우에는 영어로 작성된 개인정보처리방침이 적용됩니다. 한국어로 작성된 개인정보처리방침은 대한민국에서만 적용됩니다."
    
    //MARK: - Exception
    
    static let unknownError = "알 수 없는 오류가 발생했습니다."
}
