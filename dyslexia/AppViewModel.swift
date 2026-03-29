//
//  AppViewModel.swift
//  dyslexia

import Foundation
import Combine
import SwiftUI
import GRDB



class AppViewModel: ObservableObject {
    let appDB = AppDatabase.getInstance()
    
    private var dbObserver: DatabaseCancellable? = .none
    
    
    @Published var letters: [Letter] = []
    
    @Published var vocabulary: Set<String> = []
    
    func fetchWords() async{
        let apiURL = "https://random-word-api.herokuapp.com/word"
        let quantity = 1000
        let url = URL(string: "\(apiURL)?number=\(quantity)")
        
    
        let(rawData, rawResp) = try! await URLSession.shared.data(from: url!)
        guard let response = rawResp as? HTTPURLResponse else {return}
        debugPrint(response.statusCode)
        let decodedData = try! JSONDecoder().decode([String].self, from: rawData)
        self.vocabulary = Set(decodedData.map{$0.uppercased()})
        
        self.minLength = vocabulary.min(by: { $0.count < $1.count })!.count
        self.maxLength = vocabulary.max(by: { $0.count < $1.count })!.count
        
        if self.minLength > self.curMinLength {
            self.curMinLength = self.minLength
        }
        
        if self.curMinLength > self.curMaxLength {
            self.curMaxLength = self.maxLength
        }
        
        print(self.minLength)
        print(self.maxLength)
        print(self.curMinLength)
        print(self.curMaxLength)
        
    }
    
    
    //private let vocabulary: Set<String> = ["sol", "mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune",                                                                                       "pluto", "helium", "oxygen", "hydrogen", "carbon", "nitrogen", "neon",
                                      //     "calcium", "iron", "uranium", "phosphorous", "potassium", "copper",
                                        //   "tungsten", "titanium", "plutonium", "magnesium", "sulfur", "sodium",
                                          // "argon", "mercury", "zinc", "boron", "cobalt", "platinum", "gold",
                                           //"nickel", "chlorine", "fluorine", "bromine", "iodine", "silver" ]
    
    private let letterScore: [String:Int] = ["A":1, "E":1, "I":1, "O":1, "U":1, "L":1, "N":1,
                                             "R":1, "S":1, "T":1, "D":2, "G":2, "B":3, "C":3,
                                             "M":3, "P":3, "F":4, "H":4, "V":4, "W":4, "Y":4,
                                             "K":5, "J":8, "X":8, "Q":10, "Z": 10]
    
    // same as selectedWord in android
    private var secretWord: String = ""
    
    var minLength: Int = 0
    var maxLength: Int = 0
    
    @Published var curMinLength: Int = 0
    @Published var curMaxLength: Int = 0
    
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

    
    @Published private(set) var gameHistory: [Games] = []
    
    init () {
        Task{
            await self.fetchWords()
            
            let observation = ValueObservation.tracking(Games.fetchAll)
            self.dbObserver = .none
            let obs = observation.start(in: appDB.dbQueue, scheduling: .immediate) {
                err in print("Error in observer \(err)")
            } onChange: { (gg: [Games]) in
                Task {
                    await MainActor.run {
                        self.gameHistory = gg
                    }
                }
            }
            self.dbObserver = obs
            
            self.startNewGame()
        }
    }
    
    func startNewGame() {
        
        let prevWord = self.secretWord
        
        // don't add record if initial word
        if (!prevWord.isEmpty){
            self.addGameRecord()
        }
        
        while(self.secretWord == prevWord || self.secretWord.count < self.curMinLength || self.secretWord.count > self.curMaxLength ){
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
    
    func addGameRecord() {
        let prevRecord = self.gameHistory.last
        let curWord = self.secretWord

        print("Attempting to save game")
        if(prevRecord?.word != curWord){
            
            if (self.gameOver){
                self.totalScore += self.wordScore
            }
            else
            {
                self.wordScore = 0
            }
            
            let scoredGame = Games(word: self.secretWord, points: self.wordScore, time: self.wordTime, moves: self.moveCount)
            
            Task{
                do {
                    try await appDB.save(scoredGame)
                }
                catch {
                    print("Failed to save game")
                }
            }
                
        }
    }
    
    func sortByWord(){
        self.gameHistory.sort{ $0.word < $1.word }
    }
    
    func sortByScore(){
        self.gameHistory.sort{ $0.points > $1.points }
    }
    
    func sortByMoves(){
        self.gameHistory.sort{ $0.moves < $1.moves }
    }
    
    func sortByTime(){
        self.gameHistory.sort{ $0.time > $1.time }
    }
}
