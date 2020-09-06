//
//  ListReorder.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/24.
//

import SwiftUI

struct ListReorder: View {
    @EnvironmentObject var listManager: ListManager
    var body: some View {
        AnyView(ListReorderOriginal(cafeList: listManager.cafeList)
                .listStyle(GroupedListStyle()))
    }
}

struct ListReorderOriginal: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()
    
    @State var tempListManager = ListManager()
    
    init(cafeList: [ListElement]) {
        self.tempListManager.cafeList = cafeList
    }

    var body: some View {
        NavigationView {
            List {
                Section(header:
                           Text("고정됨").modifier(SectionText())
                            .padding([.top], 40)
                ) {
                    if (tempListManager.fixedList.isEmpty) {
                        Text("고정된 식당이 없어요")
                    }
                    ForEach(tempListManager.cafeList.filter{$0.isFixed}) { cafe in
                        Text(cafe.name)
                        .modifier(TitleText())
                    }
                    .onMove(perform: moveFixed)
                }
                Section(header:
                           Text("일반").modifier(SectionText())
                ) {
                    ForEach(tempListManager.cafeList.filter{$0.isFixed == false}) { cafe in
                        Text(cafe.name)
                        .modifier(TitleText())
                    }
                    .onMove(perform: moveUnfixed)
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationBarTitle("목록 수정", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                            self.presentationMode.wrappedValue.dismiss()}) {
                                        Text("취소")
                                            .foregroundColor(themeColor.colorTitle(colorScheme))
                                    }
                                , trailing:
                                        Button(action: {
                                                self.listManager.cafeList = self.tempListManager.cafeList
                                                self.listManager.save()
                                                self.presentationMode.wrappedValue.dismiss()}) {
                                            Text("저장")
                                                .foregroundColor(themeColor.colorTitle(colorScheme))
                                        })
        }
    }
    
    func moveFixed(from source: IndexSet, to destination: Int) {
        var intIndexSet: [Int] = []
        for index in source {
            let moveIndex = tempListManager.index(of: tempListManager.fixedList[index].name)!
            intIndexSet.append(moveIndex)
        }
        let newDestination = destination == tempListManager.fixedList.count ? tempListManager.cafeList.count : tempListManager.index(of: tempListManager.fixedList[destination].name)!
        let newSource = IndexSet(intIndexSet)
        tempListManager.cafeList.move(fromOffsets: newSource, toOffset: newDestination)
    }
    func moveUnfixed(from source: IndexSet, to destination: Int) {
        var intIndexSet: [Int] = []
        for index in source {
            let moveName = tempListManager.index(of: tempListManager.unfixedList[index].name)!
            intIndexSet.append(moveName)
        }
        let newDestination = destination == tempListManager.unfixedList.count ? tempListManager.cafeList.count : tempListManager.index(of: tempListManager.unfixedList[destination].name)!
        let newSource = IndexSet(intIndexSet)
        tempListManager.cafeList.move(fromOffsets: newSource, toOffset: newDestination)
    }

}

struct ListReorder_Previews: PreviewProvider {
    static var previews: some View {
        ListReorder()
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
