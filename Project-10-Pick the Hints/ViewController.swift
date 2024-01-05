//
//  ViewController.swift
//  Project-10-Pick the Hints
//
//  Created by suhail on 03/10/23.
//

import UIKit

class ViewController: UIViewController {
    
    var answerLetterCount = [String]()
    var tappedButtons = [UIButton]()
    var hintButtons = [UIButton]()
    var clues = [String]()
    var answers = [String]()
    var allHintSet = [String]()
    var score = 0{
        didSet{
            lblScore.text = "Score: \(score)"
        }
    }
    var level = 1
    @IBOutlet var vwBtnContainer: UIView!
    
    @IBOutlet var cluesLAbel: UILabel!
    @IBOutlet var answersLabel: UILabel!
    @IBOutlet var lblScore: UILabel!
    @IBOutlet var txtAnswer: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // vwBtnContainer.layer.cornerRadius = 7
        vwBtnContainer.layer.borderWidth = 1
        vwBtnContainer.layer.borderColor = UIColor.darkGray.cgColor
        layoutButtons()
        loadLevel(level: 1)
        
    }
    
    func layoutButtons(){
        let btnWidth = (view.frame.size.width/4)-5
        let btnHeight = 80.0
        print(vwBtnContainer.frame.size.width)
        print(btnWidth)
        for row in 0..<5{
            for col in 0..<4{
                let hintBtn = UIButton(type: .system)
                
                let frame = CGRect(x: CGFloat(col)*btnWidth, y: CGFloat(row)*btnHeight, width: btnWidth, height: btnHeight)
                hintBtn.frame = frame
                hintBtn.titleLabel?.textAlignment = .left
                hintBtn.titleLabel?.font = UIFont.systemFont(ofSize: 28)
               // hintBtn.backgroundColor = UIColor.systemRed
                //hintBtn.setTitle("SOH", for: .normal)
                hintBtn.addTarget(self, action: #selector(hintTapped),for: .touchUpInside)
                
                vwBtnContainer.addSubview(hintBtn)
                hintButtons.append(hintBtn)
                
            }
        }
    }
    @objc func hintTapped(_ sender: UIButton){
        sender.isHidden = true
        tappedButtons.append(sender)
        let previousText = txtAnswer.text
        txtAnswer.text = "\(previousText!)\(sender.titleLabel?.text ?? "")"
        
        
    }
    func loadLevel(level: Int){
        
        guard let fileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {
            print("File couldnt be fetched")
            return
        }
        guard let levelContents = try? String(contentsOf: fileURL) else {
            print("Contents of file could not be fetched")
            return }
        print(levelContents)
        let lines = levelContents.components(separatedBy: "\n")
        for line in lines{
            var clue = ""
            var hint = ""
            let currentLine = line.components(separatedBy: ":")
            hint = currentLine[0]
            clue = currentLine[1]
            clues.append(clue)
            
            //extracting indivisual hints for all hints on a particular line
            let currentAnswer = hint.replacingOccurrences(of: "|", with: "")
            answers.append(currentAnswer)
            let allLineHints = hint.components(separatedBy: "|")
         //   print(allLineHints)
            for hint in allLineHints{
                allHintSet.append(hint)
            }
            
        }
       
        configureViews()
        
    }
    
    func configureViews(){
        
        //configuring answers label
        let answerLettterCount = getLetterCount()
       
        let answerString = answerLettterCount.joined(separator: "\n")
        answersLabel.text = answerString
        //configuring clues label
        clues = clues.enumerated().map {(index,element) in
            "\(index+1). "+element
        }
        let allClues = clues.joined(separator: "\n")
        cluesLAbel.text = allClues
        //configuring buttons
        DispatchQueue.main.async{
            self.allHintSet.shuffle()
            for i in 0..<self.allHintSet.count {
                print(self.allHintSet[i])
                self.hintButtons[i].setTitle(self.allHintSet[i], for: .normal)
            }
        }
        
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        
        guard let enteredWord = txtAnswer.text else { return }
        txtAnswer.text = ""
        if answers.contains(enteredWord){
            tappedButtons.removeAll()
            score += 1
            let index = answers.firstIndex(of: enteredWord)!
            answerLetterCount[index] = enteredWord
            let joinedAnswers = answerLetterCount.joined(separator: "\n")
            DispatchQueue.main.async{
                self.answersLabel.text = joinedAnswers
            }
            
        }else{
            for button in tappedButtons {
                button.isHidden = false
            }
        }
        
        let maxScore = answers.count
        if score == maxScore{
            let ac = UIAlertController(title: "Level Complete", message: "All riddles answered sucessfully", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Next Level", style: .default, handler: { _ in
                self.levelUp()
            }))
            present(ac,animated: true)
        }
        
    }
    func levelUp(){
        score = 0
        allHintSet.removeAll(keepingCapacity: true)
        clues.removeAll(keepingCapacity: true)
        answers.removeAll(keepingCapacity: true)
        tappedButtons.removeAll(keepingCapacity: true)
        hintButtons.removeAll(keepingCapacity: true)
        answerLetterCount.removeAll(keepingCapacity: true)
        layoutButtons()
        level = level+1
        loadLevel(level: level)
    }
    @IBAction func clearTapped(_ sender: Any) {
        txtAnswer.text = ""
        //tappedButtons.removeAll()
        for button in tappedButtons {
            button.isHidden = false
        }
        
    }
    
    func getLetterCount()->[String]{
         answerLetterCount = answers.map {
            "\($0.count) letters"
        }
        return answerLetterCount
    }
}

