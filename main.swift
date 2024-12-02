//
//  ContentView.swift
//  Spotifyyyy
//
//  Created by ahmet on 12/2/24.
//

import SwiftUI
import AVFoundation
import Combine

class Model: ObservableObject {
    @Published var stateItem: [StateItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        guard let url = URL(string: "https://example.com") else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [StateItem].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] data in
                self?.stateItem = data
            })
            .store(in: &cancellables)
    }
}

struct StateItem: Codable, Identifiable {
    let id: UUID
    let songSelection: String
    let description: String
    let coverArtURL: String
    let musicURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case songSelection = "track"
        case description = "desc"
        case coverArtURL = "coverArt"
        case musicURL = "playerItem"
    }
}

struct AudioPlayer {
    var mediaPlayer = AVPlayer()
    
    func playMedia(with item: AVPlayerItem) {
        mediaPlayer.replaceCurrentItem(with: item)
        mediaPlayer.play()
    }
}

struct ContentView: View {
    @State var isPlaying: Bool = false
    @State var label: String = "Play"
    @EnvironmentObject var model: Model
    @State var sModel: StateModel = StateModel(songName: "null", coverImage: Image(systemName: "globe"))
    
    var body: some View {
        ZStack {
            VStack {
                List(model.stateItem) { art in
                    HStack(spacing: 5) {
                        AsyncImage(url: URL(string: art.coverArtURL)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "photo").resizable().scaledToFit()
                        }
                        .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text(art.songSelection).font(.headline)
                            Text(art.description).font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Button(label) {
                            isPlaying.toggle()
                            label = isPlaying ? "Stop" : "Play"
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    sModel.coverImage
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Text(sModel.songName)
                    
                    Button(label) {
                        isPlaying.toggle()
                        label = isPlaying ? "Stop" : "Play"
                    }
                    .frame(width: 100, height: 40)
                    .foregroundColor(.white)
                    .background(isPlaying ? Color.red : Color.green)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .onAppear {
            model.fetchData()
        }
    }
}

struct StateModel {
    var songName: String
    var coverImage: Image
}

#Preview {
    ContentView().environmentObject(Model())
}
