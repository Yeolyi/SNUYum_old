//
//  iOS1314List.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/02.
//

import SwiftUI

func listByVersion(view: AnyView) -> AnyView {
    if #available(iOS 14.0, *) {
        return AnyView(
        view
            .listStyle(GroupedListStyle())
            //.listStyle(InsetGroupedListStyle())
        )
    }
    else {
        return AnyView(
            view
            .listStyle(GroupedListStyle())
        )
    }
}
