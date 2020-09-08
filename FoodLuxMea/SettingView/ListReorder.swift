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
        VStack {
            HStack {
                TitleView(title: "목록 수정", subTitle: "설정")
                Button(action: {
                         self.presentationMode.wrappedValue.dismiss()}) {
                     Text("취소")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.black)
                        .padding()
                        .offset(y: 10)
                 }
            }
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
                                       
           Button(action: {
              self.listManager.cafeList = self.tempListManager.cafeList
              self.listManager.save()
              self.presentationMode.wrappedValue.dismiss()}) {
                  Text("저장")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.black)
                    .offset(y: 10)
           }
            
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
