//
//  SwiftUIView.swift
//  SnuYumAppClip
//
//  Created by Seong Yeol Yi on 2020/09/25.
//

import SwiftUI

struct SwiftUIView: View {
    @State var num = 0
    var body: some View {
        VStack {
            Button(action: {num+=1}) {
                Text("누르세용")
            }
            ForEach(0..<num) {_ in
                Text("오은성 바보")
                    .font(.largeTitle)
                    .foregroundColor(.red)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
