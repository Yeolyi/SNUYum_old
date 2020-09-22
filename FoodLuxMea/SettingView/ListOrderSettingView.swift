//
//  ListReorder.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/24.
//

import SwiftUI

/// Provides list edit mode to reorder cafe list in main view.
struct ListOrderSettingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    
    @State var tempListManager = ListManager()
    
    /// - Parameter cafeListBackup: Backup [ListElement] to restore data when sheet is closed or dismissed
    init(cafeListBackup: [ListElement]) {
        tempListManager.cafeList = cafeListBackup
    }
    
    var body: some View {
        VStack {
            // MARK: - Custom navigation bar
            HStack {
                customNavigationBar(title: "목록 수정", subTitle: "설정")
                Spacer()
                Button(action: {
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("취소")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .offset(y: 10)
                }
                Button(action: {
                        self.listManager.cafeList = self.tempListManager.cafeList
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("저장")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            // MARK: - List(editMode true)
            List {
                Section(header:
                            Text("고정됨")
                            .sectionText()
                            .padding([.top], 40)
                ) {
                    if tempListManager.fixedList.isEmpty {
                        Text("고정된 식당이 없어요")
                    }
                    ForEach(tempListManager.cafeList.filter { $0.isFixed }) { cafe in
                        Text(cafe.name)
                            .accentedText()
                    }
                    .onMove(perform: moveFixed)
                }
                Section(header:
                            Text("일반").sectionText()
                ) {
                    ForEach(tempListManager.cafeList.filter { $0.isFixed == false }) { cafe in
                        Text(cafe.name)
                            .accentedText()
                    }
                    .onMove(perform: moveUnfixed)
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .listStyle(GroupedListStyle())
        }
    }
    
    /// Move ListElement which is fixed
    func moveFixed(from source: IndexSet, to destination: Int) {
        var intIndexSet: [Int] = []
        for index in source {
            if let moveIndex = tempListManager.index(of: tempListManager.fixedList[index].name) {
                intIndexSet.append(moveIndex)
            }
        }
        if let destinationIndex = tempListManager.index(of: tempListManager.fixedList[destination].name) {
            let newDestination =
                destination == tempListManager.fixedList.count ? tempListManager.cafeList.count : destinationIndex
            let newSource = IndexSet(intIndexSet)
            tempListManager.cafeList.move(fromOffsets: newSource, toOffset: newDestination)
        }
    }
    
    /// Move ListElement which is not fixed
    func moveUnfixed(from source: IndexSet, to destination: Int) {
        var intIndexSet: [Int] = []
        for index in source {
            if let moveName = tempListManager.index(of: tempListManager.unfixedList[index].name) {
                intIndexSet.append(moveName)
            }
        }
        if let destinationIndex = tempListManager.index(of: tempListManager.unfixedList[destination].name) {
            let newDestination =
                destination == tempListManager.unfixedList.count ? tempListManager.cafeList.count : destinationIndex
            let newSource = IndexSet(intIndexSet)
            tempListManager.cafeList.move(fromOffsets: newSource, toOffset: newDestination)
        }
    }
}

struct ListReorder_Previews: PreviewProvider {
    static var previews: some View {
        ListOrderSettingView(cafeListBackup: [])
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
