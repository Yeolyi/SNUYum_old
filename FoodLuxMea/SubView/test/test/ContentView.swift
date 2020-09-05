//
//  ContentView.swift
//  test
//
//  Created by Seong Yeol Yi on 2020/09/02.
//  Copyright © 2020 WannaSleep. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            Text("Hello, World!")
                .foregroundColor(Color(.blue))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
