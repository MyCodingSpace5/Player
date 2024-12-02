//
//  ContentView.swift
//  Spotifyyyy
//
//  Created by ahmet on 12/2/24.
//

import SwiftUI
import AVFoundation
import Combine


class Model: ObservableObject{
    @Published var stateItem: [StateItem]
    private var cancellables = Set<AnyCancellable>()
    init(stItem: [StateItem]){
        self.stateItem = stItem
    }
    func fetchData(){
        guard let url = URL(string: "https://example.com") else {return}
        URLSession.shared.dataTaskPublisher(for: url)
            .map{$0.data}
            .decode(type: [StateItem].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                [weak self] completion -> Void in
                completion.receiveValue {
                    [weak self] data in
                    self?.stateItem = data
                }
            }
            .store(in: &cancellables)
        
    }
}
struct StateModel{
    var songName: String
    var coverImage: Image
}
struct StateItem: Codable, Identifiable{
    let id: Int
    let uuid: ObjectIdentifier
    let songSelection: String
    let description: String
    let coverArt: Image
    let music: AVPlayerItem
    enum jsonIdentifiers: String, CodingKey{
        case id
        case track
        case desc
        case covertArt
        case playerItem
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: jsonIdentifiers.self)
        self.id = try container.decode(Int.self, forKey: jsonIdentifiers.id)
        self.songSelection = try container.decode(String.self, forKey: jsonIdentifiers.track)
        self.description = try container.decode(String.self, forKey: jsonIdentifiers.desc)
        self.coverArt = try container.decode(Image.self, forKey: jsonIdentifiers.covertArt)
        self.music = try container.decode(AVPlayerItem.self, forKey: jsonIdentifiers.playerItem)
    }
}
struct AudioPlayer{
    var mediaPlayer: AVPlayer
    var mediaItem: AVPlayerItem
    func playMedia(){
        mediaPlayer.play(mediaItem)
    }
}
struct ContentView: View {
    @State var isPlaying: Bool = false
    @EnvironmentObject var model: Model
    @State var sModel: StateModel = StateModel(songName: "null", coverImage: Image(systemName: "globe"))
    var body: some View {
        ZStack{
            VStack{
                List(model.stateItem){ art in
                    HStack(spacing: 5){
                        art.coverArt
                        Text(art.songSelection)
                        VStack{
                            Text(art.description)
                        }.padding(.bottom)
                        Spacer()
                        Button("Play"){
                            sModel = sModel.init(songName: art.songSelection, coverImage: art.coverArt)
                            self.label = isPlaying != false ? "Stop" : "Play"
                        }
                    }
                }
            }
            VStack {
                Spacer()
                HStack{
                    sModel.coverImage
                    Text("\(sModel.songName)")
                    Button(self.label, isPlaying != false ? "Stop" : "Play"){
                        print("Hi!")
                    }.frame(width: 40, height: 30)
                        .foregroundColor(.green)
                        .background(.green)
                        .cornerRadius(40)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
