//
//  SelectedGameHistory.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/7/26.
//

import SwiftUI

struct SelectedGameHistory: View {
    let record: Games
    
    var body: some View {
        VStack{
            Text("Selected Game History")
            Text(" ")
            Text("Word: \(record.word)")
            Text("Score: \(record.points)")
            Text("Moves: \(record.moves)")
            Text("Time: \(record.time)")
            Spacer()
        }
    }
}
