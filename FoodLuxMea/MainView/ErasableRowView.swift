//
//  ErasableRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/23.
//

import SwiftUI

struct ErasableRow: View {
    
    @EnvironmentObject var erasableRowManager: ErasableRowManager
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    
    var body: some View {
        ForEach(erasableRowManager.erasableMessages) { erasableMessage in
            HStack {
                Text(erasableMessage)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        withAnimation {
                            erasableRowManager.remove(erasableMessage)
                        }
                    }
                    .padding(5)
            }
            .transition(.opacity)
            .rowBackground()
        }
    }
}

struct ErasableRow_Previews: PreviewProvider {
    static var previews: some View {
        ErasableRow()
    }
}
