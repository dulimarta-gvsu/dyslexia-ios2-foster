//
//  WordScreen.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/7/26.
//

import SwiftUI

struct WordScreen: View{
    init(viewModel: AppViewModel, onHistory: @escaping () -> Void, onOptions: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onHistory = onHistory
        self.onOptions = onOptions
    }
    @ObservedObject private var viewModel: AppViewModel
    @State private var letters: [Letter] = []
    
    private var onHistory: () -> Void
    private var onOptions: () -> Void

    var body: some View {
        VStack {
            HStack{
                Text("Total Score: \(viewModel.totalScore)")
                Text("Moves: \(viewModel.moveCount)")
                Text("Time: \(viewModel.wordTime)")
            }
            Button("New") {
                viewModel.startNewGame()
            }.buttonStyle(.borderedProminent)
            Spacer()
            LetterGroup(letters: $letters, color: $viewModel.bgColor) { arr in
                let z = arr.prettyPrint()
                print("Rearrange \(z)")
                viewModel.rearrange(to: arr)
            } onIncrementMoveCount: {
                viewModel.incrementMoveCount()
            }
            Spacer()
            HStack{
                Button("Game History"){
                    self.onHistory()
                }.buttonStyle(.borderedProminent)
                Button("Game Options"){
                    self.onOptions()
                }.buttonStyle(.borderedProminent)
            }
        }
        .onChange(of: viewModel.gameOver) {
            if (viewModel.gameOver){
                viewModel.stopTimer()
                viewModel.addGameRecord()
            }
        }
        .alert(isPresented: $viewModel.gameOver){
            Alert(
                title: Text("Game Over"),
                message: Text("""
                        Number of Moves: \(viewModel.moveCount)
                        Time to Solve: \(viewModel.wordTime) seconds
                        Word Score: \(viewModel.wordScore)
                        """),
                
                primaryButton: .default(
                    Text("Play Again"),
                    action: viewModel.startNewGame),
                secondaryButton: .default(
                    Text("Done"),
                    action: viewModel.addGameRecord))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.yellow)
        .onReceive(viewModel.$letters) { newValue in
            print("New word in content view")
            letters = newValue
        }
        
    }
}
