//
//  ContentView.swift
//  Pokemon
//
//  Created by Olga Rastelli on 17/06/23.


import SwiftUI

struct WelcomeLoader: View {
    @State private var isLoading = true
    
        var body: some View {
            ZStack {

                if isLoading {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            VStack {
                                GetLoaderImage()

                            }
                        )
                }
            }
            .onAppear {
                // Simulazione del caricamento dei dati
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                    
                }
               
            }
            
         
        }
    }


struct GetLoaderImage: View {
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            if let downloadedImage = image {
                Image(uiImage: downloadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Immagine non disponibile")
            }
        }
        .onAppear {
            downloadImageFromURL()
        }
    }
    
    func downloadImageFromURL() {
        guard let url = URL(string: "https://fontmeme.com/images/Pokemon-Logo.jpg") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                image = UIImage(data: data)
            }
        }.resume()
    }
}











