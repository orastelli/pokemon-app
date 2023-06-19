//
//  ContentView.swift
//  Pokemon
//
//  Created by Olga Rastelli on 17/06/23.
//
import SwiftUI

struct ContentView: View {
    @State private var showLoader = true
    
    var body: some View {
        Group {
            if showLoader {
                WelcomeLoader()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showLoader = false
                        }
                    }
            } else {
               ShowPokedex()
            }
        }
    }
}
