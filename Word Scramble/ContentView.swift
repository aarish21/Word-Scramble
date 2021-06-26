//
//  ContentView.swift
//  Word Scramble
//
//  Created by Aarish Rahman on 26/06/21.
//

import SwiftUI

struct ContentView: View {
    init() {
           UITableView.appearance().backgroundColor = .clear
           UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
       }
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
       
        NavigationView{
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray]), startPoint: .leading, endPoint: .trailing).edgesIgnoringSafeArea(.all)
                VStack{
                    TextField("Enter words here", text: $newWord, onCommit: addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        
                        
                    List(usedWords, id: \.self){
                        Image(systemName: "app.fill").foregroundColor(.gray)
                        Text($0)
                    }
                    .listRowBackground(Color.clear)
                    .listStyle(InsetListStyle())
                    Text("Score \(usedWords.count)")
                    
                    
                }
                .navigationBarTitle(rootWord)
                .onAppear(perform: startGame)
                .navigationBarItems(trailing:
                                        Button(action: startGame){
                                            Text("Start Game")
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                        })
                .alert(isPresented: $showingError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        
                }
            }
            
        }
    }
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    func startGame(){
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkWorm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
      var tempWord = rootWord

      for letter in word {
        if let pos = tempWord.firstIndex(of: letter) {
          tempWord.remove(at: pos)
        } else {
          return false
        }
      }

      return true
    }
    func isReal(word: String) -> Bool {
        if word.count<3{
            return false
        }
        if word == rootWord{
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
