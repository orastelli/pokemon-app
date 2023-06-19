import SwiftUI

struct Pokemon: Identifiable {
    let id = UUID()
    let name: String
    let imageURL: String
}

struct ShowPokedex: View {
    @State private var showPokedex = false
    @State private var pokemonImages: [String] = []
    @State private var selectedPokemon: Pokemon? = nil
    
    
    var body: some View {
        if showPokedex {
            VStack {
                HStack {
                    Button(action: {
                        showPokedex = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding()
                    
                    Text("Pokédex Kanto")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                        
                    
                    Spacer()
                }
                .background(Color.yellow)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(pokemonImages, id: \.self) { imageURL in
                            Button(action: {
                                if let pokemon = getPokemon(from: imageURL) {
                                    selectedPokemon = pokemon
                                }
                            }) {
                                RemoteImage(url: imageURL)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 100)
                            }
                        }
                    }
                    .padding()
                }
            }
            .alert(item: $selectedPokemon) { pokemon in
                Alert(title: Text(pokemon.name), message: nil, dismissButton: .default(Text("Close")))
  
            }
        } else {
            VStack {
                Button(action: {
                    fetchPokemonImages()
                }) {
                    Text("Mostra Pokemon")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // Funzione per recuperare le immagini dei Pokémon
    func fetchPokemonImages() {
        let baseURL = "https://pokeapi.co/api/v2"
        let endpoint = "/pokemon?limit=151" // Recupera i primi 151 Pokémon
        
        guard let url = URL(string: baseURL + endpoint) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Errore nella richiesta: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                    let imageURLs = result.results.map { $0.imageURL }
                    
                    DispatchQueue.main.async {
                        self.showPokedex = true
                        self.pokemonImages = imageURLs
                    }
                } catch {
                    print("Errore nel parsing dei dati: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // Struttura dati per rappresentare il nome del Pokémon ottenuto dall'API
    struct PokemonNameResponse: Decodable {
        let name: String
    }

    // Funzione per ottenere le informazioni del Pokémon corrispondente all'URL dell'immagine
    func getPokemon(from imageURL: String) -> Pokemon? {
        if let pokemonIndex = pokemonImages.firstIndex(of: imageURL) {
            let pokemonNumber = pokemonIndex + 1
            getPokemonName(pokemonNumber: pokemonNumber) { name in
                if let name = name {
                    let pokemon = Pokemon(name: name, imageURL: imageURL)
                    selectedPokemon = pokemon
                }
            }
        }
        return nil
    }

    // Funzione per recuperare il nome del Pokémon dato il numero
    func getPokemonName(pokemonNumber: Int, completion: @escaping (String?) -> Void) {
        let baseURL = "https://pokeapi.co/api/v2"
        let endpoint = "/pokemon/\(pokemonNumber)"
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Errore nella richiesta: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    let pokemonNameResponse = try JSONDecoder().decode(PokemonNameResponse.self, from: data)
                    completion(pokemonNameResponse.name)
                } catch {
                    print("Errore nel parsing dei dati: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }.resume()
    }

    struct PokemonDetails: View {
        let pokemon: Pokemon
        @Binding var isPresented: Bool
        
        var body: some View {
            VStack {
                Text(pokemon.name)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Close")
                }
            }
            .padding()
        }
    }
   

}

struct RemoteImage: View {
    @ObservedObject private var imageLoader: ImageLoader
    
    init(url: String) {
        _imageLoader = ObservedObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        if imageLoader.isLoading {
            ProgressView() // Visualizza un loader di caricamento mentre l'immagine viene scaricata
        } else {
            Image(uiImage: imageLoader.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage = UIImage()
    @Published var isLoading = false
    
    init(url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Errore nel download dell'immagine: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

struct PokemonListResponse: Decodable {
    let results: [Pokemon]
    
    struct Pokemon: Decodable {
        let name: String
        let url: String
        
        var imageURL: String {
            let pokemonID = url.components(separatedBy: "/").dropLast().last ?? ""
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonID).png"
        }
    }
}
