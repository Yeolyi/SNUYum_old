//
//  SettingView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/24.
//

import SwiftUI
import GoogleMobileAds
import FirebaseAuth
import GoogleSignIn

/// Indicate which type of setting sheet is shown.
enum SettingSheet: Identifiable {
    // ID to use iOS 14 compatible 'item' syntax in sheet modifier.
    var id: Int {
        self.hashValue
    }
    case reorder, timer, info, account
}

struct SettingView: View {
    
    @Binding var isPresented: Bool
    @State var activeSheet: SettingSheet?
    @State var logOutAlert = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    let themeColor = ThemeColor()
    
    var loginMethodStr: String {
        if let id = Auth.auth().currentUser?.providerData.first?.providerID {
            switch id {
            case "apple.com":
                return "애플로 로그인 완료!"
            case "google.com":
                return "구글로 로그인 완료!"
            default:
                return "로그인 완료!"
            }
        } else {
            return "로그인 완료!"
        }
    }
    
    /// - Parameter isPresented: Pass main view to show current view or not.
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        // List rows
        ScrollView {
            VStack(spacing: 0) {
                // Prevents BlurHeader hides scrollview object.
                Text("")
                    .padding(45)
                Group {
                    Text("기본")
                        .sectionText()
                    // Basic setting - Cafe reorder.
                    Button(action: {
                        self.activeSheet = .reorder
                    }) {
                        HStack {
                            Text("식당 순서 변경")
                                .font(.system(size: 18))
                                .foregroundColor(themeColor.title(colorScheme))
                            Spacer()
                            if listManager.fixedList.count != 0 {
                                Text("\(listManager.fixedList.count)개 식당이 고정되었어요")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.gray))
                            } else {
                                Text("고정된 식당이 없어요")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .rowBackground()
                        .contentShape(Rectangle())
                    }
                    // Basic setting - Cafe timer.
                    Button(action: {
                        self.activeSheet = .timer
                    }) {
                        HStack {
                            Text("기준 식당 선택")
                                .font(.system(size: 18))
                                .foregroundColor(themeColor.title(colorScheme))
                            Spacer()
                            Text(settingManager.alimiCafeName ?? "꺼짐")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .rowBackground()
                        .contentShape(Rectangle())
                    }
                }
                // Basic setting - Hide empty cafe.
                SimpleToggle(isOn: $settingManager.hideEmptyCafe, label: "메뉴가 없는 식당 숨기기")
                    .rowBackground()
                Text("계정")
                    .sectionText()
                Button(action: {
                    self.activeSheet = .account
                }) {
                    HStack {
                        Text("로그인")
                            .font(.system(size: 18))
                            .foregroundColor(themeColor.title(colorScheme))
                        Spacer()
                        Text(appStatus.userID != nil ? loginMethodStr : "로그인 후 더 많은 기능을 사용하세요")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .rowBackground()
                    .contentShape(Rectangle())
                }
                if appStatus.userID != nil {
                    Button(action: {
                        self.logOutAlert = true
                    }) {
                        HStack {
                            Text("로그아웃")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .rowBackground()
                        .contentShape(Rectangle())
                    }
                }
            }
            // Info
            Text("정보")
                .sectionText()
            Button(action: { activeSheet = SettingSheet.info }) {
                HStack {
                    Text("스누냠 정보")
                        .foregroundColor(themeColor.title(colorScheme))
                        .font(.system(size: 18))
                    Spacer()
                }
            }
            .rowBackground()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        // Caution: Sheet modifier position matters.
        .sheet(item: self.$activeSheet) { item in
            switch item {
            case .reorder:
                ListOrderSettingView()
                    .environmentObject(self.listManager)
                    .environmentObject(self.settingManager)
            case .timer:
                TimerCafeSettingView()
                    .environmentObject(self.listManager)
                    .environmentObject(self.settingManager)
            case .info:
                AboutAppView()
                    .environmentObject(self.settingManager)
                    .environmentObject(self.listManager)
                    .environmentObject(self.dataManager)
            case .account:
                AccountSetting()
            }
        }
        .alert(isPresented: $logOutAlert) {
            Alert(
                title: Text("로그아웃하시겠어요?"),
                message: Text("일부 기능이 제한돼요"),
                primaryButton: .cancel(),
                secondaryButton: .default(
                    Text("로그아웃하기"),
                    action: {
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            appStatus.userID = nil
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                )
            )
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            SettingView(isPresented: .constant(true))
                .environmentObject(CafeList())
                .environmentObject(Cafeteria())
                .environmentObject(UserSetting())
        }
    }
}
