//
//  ViewController.swift
//  Hangman
//
//  Created by Olga Berezka on 24.01.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var scoreLabel: UILabel!
    var wrongAttemptsLabel: UILabel!
    
    var currentAnswer: UITextField!
    var chosenLetter: UILabel!
    
    var letterButtons = [UIButton]()
    var tappedButtons = [UIButton]()
    
    var words = [String]()
    var currentWord = String()
    var promptWord = [String]()
    var usedLetters = [Character]()
    
    var wrongAttempts = 0 {
        didSet {
            wrongAttemptsLabel.text = "Wrong attempts: \(wrongAttempts)"
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "&", "-"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
        score = 0
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        //scoreLabel.text = "Score:"
        scoreLabel.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(scoreLabel)
        
        wrongAttemptsLabel = UILabel()
        wrongAttemptsLabel.translatesAutoresizingMaskIntoConstraints = false
        wrongAttemptsLabel.textAlignment = .left
        //attemptsLeftLabel.text = "Wrong Answers:"
        wrongAttemptsLabel.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(wrongAttemptsLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let reloadButton = UIButton(type: .system)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.setTitle("RELOAD", for: .normal)
        view.addSubview(reloadButton)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 40),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -40),
            
            wrongAttemptsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wrongAttemptsLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            wrongAttemptsLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 40),
            
            currentAnswer.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 100),
            currentAnswer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 40),
            
            buttonsView.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 40),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 40),
            
            reloadButton.topAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: 60),
            reloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reloadButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -100),
        ])
        
        
        let width = 100
        let height = 60
        
        // create 20 buttons as a 4x5 grid
        for row in 0..<4 {
            for col in 0..<7 {
                // create a new button and give it a big font size
                let letterButton = UIButton(type: .system)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                
                // give the button some temporary text so we can see it on-screen
                // letterButton.setTitle("W", for: .normal)
                
                // calculate the frame of this button using its column and row
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                // add it to the buttons view
                buttonsView.addSubview(letterButton)
                
                // and to the letterButtons array
                letterButtons.append(letterButton)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
            }
        }
    }
    
    @objc func parseWords() {
        
        if let wordsFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let wordsContents = try? String(contentsOf: wordsFileURL) {
                var words = wordsContents.components(separatedBy: ",")
                words.shuffle()
                print(words)
                
                currentWord = words.randomElement()!
                print(currentWord)
                
            }
        }
    }
    
    @objc func setPrompt() {
        
        for letter in currentWord {
            usedLetters.append(letter)
            promptWord.append("?")
        }
        print("Used letters: \(usedLetters)")
        print("Prompt word: \(promptWord)")
        
        currentAnswer.text = promptWord.joined()
    }
    
    @objc func setButtonsTitle() {
        for i in 0 ..< alphabet.count {
            letterButtons[i].setTitle(alphabet[i], for: .normal)
        }
        
    }
    
    @objc func loadLevel(action: UIAlertAction! = nil) {
        
        wrongAttempts = 0
        performSelector(inBackground: #selector(parseWords), with: nil)
        performSelector(onMainThread: #selector(setButtonsTitle), with: nil, waitUntilDone: false)
        performSelector(onMainThread: #selector(setPrompt), with: nil, waitUntilDone: false)
        
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        
        tappedButtons.append(sender)
        sender.isHidden = true
        sender.isUserInteractionEnabled = false
        
        guard let stringLetter = sender.titleLabel?.text else { return }
        
        if usedLetters.contains(Character(stringLetter)) {
            
            for (index, character) in usedLetters.enumerated() {
                if character == Character(stringLetter) {
                    promptWord[index] = stringLetter
                    currentAnswer.text = promptWord.joined().uppercased()
                }
            }
            
            if currentAnswer.text == currentWord {
                
                
                let ac = UIAlertController(title: "Yes!", message: "", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Go to next level", style: .default, handler: nextLevel))
                present(ac, animated: true, completion: nil )
                
            }
        }  else {
            
            wrongAttempts += 1
            
            let ac = UIAlertController(title: "Wrong!", message: "Choose another letter", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func nextLevel(action: UIAlertAction) {
        score += 1
        reloadTapped()
    }
    
    @objc func reloadTapped() {
        
        for btn in tappedButtons {
            btn.isHidden = false
            btn.isUserInteractionEnabled = true
        }
        
        tappedButtons.removeAll()
        usedLetters.removeAll()
        promptWord.removeAll()
        loadLevel()
    }
}

