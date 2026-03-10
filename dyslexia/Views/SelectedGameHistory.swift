//
//  SelectedGameHistory.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/7/26.
//

import SwiftUI

struct SelectedGameHistory: View {
    let record: AppViewModel.WordRecord
    
    var body: some View {
        VStack{
            Text("Selected Game History")
            Text(" ")
            Text("Word: \(record.word)")
            Text("Score: \(record.score)")
            Text("Moves: \(record.moves)")
            Text("Time: \(record.time)")
            Spacer()
        }
    }
}
