//
//  AppViewModel.swift
//  dyslexia

import Foundation
import Combine
import SwiftUI

class AppViewModel: ObservableObject {
    @Published var letters: [Letter] = []
    
    private let vocabulary: Set<String> = ["sol", "mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune",                                                                                       "pluto", "helium", "oxygen", "hydrogen", "carbon", "nitrogen", "neon",
                                           "calcium", "iron", "uranium", "phosphorous", "potassium", "copper",
                                           "tungsten", "titanium", "plutonium", "magnesium", "sulfur", "sodium",
                                           "argon", "mercury", "zinc", "boron", "cobalt", "platinum", "gold",
                                           "nickel", "chlorine", "fluorine", "bromine", "iodine", "silver" ]
    
    private let letterScore: [String:Int] = ["A":1, "E":1, "I":1, "O":1, "U":1, "L":1, "N":1,
                                             "R":1, "S":1, "T":1, "D":2, "G":2, "B":3, "C":3,
                                             "M":3, "P":3, "F":4, "H":4, "V":4, "W":4, "Y":4,
                                             "K":5, "J":8, "X":8, "Q":10, "Z": 10]
    
    // same as selectedWord in android
    private var secretWord: String = ""
    
    let minLength: Int
    let maxLength: Int
    
    @Published var curMinLength: Int
    @Published var curMaxLength: Int
    
    var lengthRange: ClosedRange<Int> { curMinLength...curMaxLength }

    @Published var wordScore: Int = 0
    @Published var totalScore: Int = 0
    
    @Published var moveCount: Int = 0
    
    @Published var gameOver = false
    
    @Published var bgColor: Color = .mint
    
    func incrementMoveCount(){
        if self.timer.isValid{
            self.moveCount += 1
        }
    }
    
    private var timer: Timer = Timer()
    @Published var wordTime: Int = 0

    func startTimer(){
        self.resetTimer()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            self.wordTime += 1
        }
    }
    
    func stopTimer(){
        self.timer.invalidate()
    }
    
    func resetTimer(){
        self.stopTimer()
        
        self.wordTime = 0
    }
    
    struct WordRecord: Identifiable, Equatable, Hashable {
        let id: UUID = UUID()
        let word: String
        let score: Int
        let moves: Int
        let time: Int
    }
    
    @Published var gameHistory: [WordRecord] = []
    
    init () {
        self.minLength = vocabulary.min(by: { $0.count < $1.count})!.count
        self.maxLength = vocabulary.max(by: { $0.count < $1.count})!.count
        self.curMinLength = self.minLength
        self.curMaxLength = self.maxLength
        
        self.startNewGame()
    }
    
    func startNewGame() {
        
        let prevWord = self.secretWord
        
        // don't add record if initial word
        if (!prevWord.isEmpty){
            self.addGameRecord()
        }
        
        while(self.secretWord == prevWord){
            self.secretWord = vocabulary.randomElement()!.uppercased()
        }
        
        self.letters.removeAll()
        self.letters.append(contentsOf: self.secretWord
            .uppercased()
            .map { Letter(text:String($0),point:letterScore[String($0)]!) }
            .shuffled())
        
        self.wordScore = self.letters.reduce(0) { $0 + $1.point }
        self.gameOver = false
        self.moveCount = 0
        
        self.startTimer()
    }
    
    func rearrange(to: Array<Letter>) {
        self.letters = to
        
        let curWordState = self.letters.map { $0.text }.joined()
        
        if (curWordState == self.secretWord && self.timer.isValid){
            self.gameOver = true
        }
    }
    
    func addGameRecord(){
        let prevRecord = self.gameHistory.last
        
        if(prevRecord?.word != self.secretWord){
            if (self.gameOver){
                self.totalScore += self.wordScore
            }
            else
            {
                self.wordScore = 0
            }
            
            let newRecord = WordRecord(word: self.secretWord, score: self.wordScore, moves: self.moveCount, time: self.wordTime)
            
            self.gameHistory.append(newRecord)
        }
    }
    
    func sortByWord(){
        self.gameHistory.sort{ $0.word < $1.word }
    }
    
    func sortByScore(){
        self.gameHistory.sort{ $0.score > $1.score }
    }
    
    func sortByMoves(){
        self.gameHistory.sort{ $0.moves < $1.moves }
    }
    
    func sortByTime(){
        self.gameHistory.sort{ $0.time > $1.time }
    }
}
