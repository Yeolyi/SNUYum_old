//
//  ListSectionNameText.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

struct ListCafeNameView: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.title)
    }
}

struct ListCafeNameView_Previews: PreviewProvider {
    static var previews: some View {
        ListCafeNameView(name: "학생회관")
    }
}
