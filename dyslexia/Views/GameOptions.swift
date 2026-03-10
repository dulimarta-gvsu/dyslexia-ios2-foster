//
//  GameOptions.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/7/26.
//

import SwiftUI

struct GameOptions: View {
    init(viewModel: AppViewModel){
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    @ObservedObject var viewModel: AppViewModel
    
    
    var body: some View {
        Text("Game Options")
        Spacer()
        Text("Word Length")
        Slider(value: Binding(
            get: {Double(viewModel.curMinLength)},
            set: {viewModel.curMinLength = Int($0)}
        ), in: Double(viewModel.minLength)...Double(viewModel.curMaxLength)).padding(.horizontal, 64)
        Text("Minimum Length: \(Int(viewModel.curMinLength))")
        Slider(value: Binding(
            get: {Double(viewModel.curMaxLength)},
            set: {viewModel.curMaxLength = Int($0)}
        ), in: Double(viewModel.curMinLength)...Double(viewModel.maxLength)).padding(.horizontal, 64)
        Text("Maximum Length: \(Int(viewModel.curMaxLength))")
        Spacer()
        ColorPicker("Tile Color", selection: $viewModel.bgColor).padding(.horizontal, 64)
        Spacer()
    }
}
