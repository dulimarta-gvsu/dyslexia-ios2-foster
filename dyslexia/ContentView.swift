//
//  ContentView.swift
//  dyslexia

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var navCtrl = Navigator()
    @State var viewModel = AppViewModel()
    var body: some View {
        NavigationStack(path: $navCtrl.navPath){
            WordScreen(viewModel: viewModel){
                navCtrl.navigate(to: .GameHistory)
            } onOptions: {
                navCtrl.navigate(to: .GameOptions)
            }
            
            .navigationDestination(for: Route.self) { dest in
                switch dest {
                case .GameHistory:
                    GameHistory(viewModel: viewModel){
                        navCtrl.navigate(to: .SelectedGameHistory($0))
                    }
                    
                case .SelectedGameHistory(let record):
                    SelectedGameHistory(record: record)
                    
                case .GameOptions:
                    GameOptions(viewModel: viewModel)
                }
                
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: AppViewModel())
    }
}
#endif

