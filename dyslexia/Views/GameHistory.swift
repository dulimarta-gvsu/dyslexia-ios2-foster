//
//  GameHistory.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/7/26.
//

import SwiftUI

struct GameHistory: View {
    
    init(viewModel: AppViewModel, onSelectedGameHistory: @escaping (Games) -> Void){
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onSelectedGameHistory = onSelectedGameHistory
    }

    
    @ObservedObject private var viewModel: AppViewModel
    
    private var onSelectedGameHistory: (Games) -> Void
    
    var body: some View {
        VStack{
            Text("Game History")
            
            ScrollView{
                LazyVStack(spacing: 10){
                    ForEach(viewModel.gameHistory) { record in
                        HStack {
                            Text(record.word)
                            Spacer()
                            Text(record.points > 0 ? "Completed" : "Incomplete")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { self.onSelectedGameHistory(record) }
                        
                        if record.id != viewModel.gameHistory.last?.id {
                            Divider()
                        }
                    }
                }
            }.padding(16)
            Spacer()
            HStack{
                Button("Sort By Word"){
                    viewModel.sortByWord()
                }.buttonStyle(.borderedProminent)
                Button("Sort By Score"){
                    viewModel.sortByScore()
                }.buttonStyle(.borderedProminent)
            }
            HStack{
                Button("Sort By Moves"){
                    viewModel.sortByMoves()
                }.buttonStyle(.borderedProminent)
                Button("Sort By Time"){
                    viewModel.sortByTime()
                }.buttonStyle(.borderedProminent)
            }
        }
    }
}
