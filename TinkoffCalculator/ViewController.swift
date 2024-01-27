//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Булат Камалетдинов on 25.01.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ firstNumber: Double, _ secondNumber: Double) throws -> Double {
        switch self {
        case .add:
            return firstNumber + secondNumber
        case .substract:
            return firstNumber - secondNumber
        case .multiply:
            return firstNumber * secondNumber
        case .divide:
            if secondNumber == 0 {
                throw CalculationError.dividedByZero
            }
            return firstNumber / secondNumber
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [(expression: [CalculationHistoryItem], result: Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetResultLabelText()
        historyButton.accessibilityIdentifier = "toHistoryPageButton"
    }
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else { return }
        
        if buttonText == "," && resultLabel.text?.contains(",") == true {
            return
        }
        
        if (resultLabel.text == "0" && buttonText == ",") || (resultLabel.text != "0" && resultLabel.text != "🧮 Ошибка 🧮") {
            resultLabel.text?.append(buttonText)
        } else if resultLabel.text == "🧮 Ошибка 🧮" && buttonText == "," {
            resultLabel.text = "0\(buttonText)"
        } else {
            resultLabel.text = buttonText
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.titleLabel?.text,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        guard
            let resultLabelText = resultLabel.text,
            let resultLabelNumber = numberFormatter.number(from: resultLabelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(resultLabelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetResultLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        resetResultLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let resultLabelText = resultLabel.text,
            let resultLabelNumber = numberFormatter.number(from: resultLabelText)?.doubleValue
        else { return }
        
        if resultLabel.text == "," {
            return
        }
        
        calculationHistory.append(.number(resultLabelNumber))
        
        do {
            let result = try calculate()
            
            resultLabel.text = numberFormatter.string(from: NSNumber(value: result))
            calculations.append((calculationHistory, result))
        } catch {
            resultLabel.text = "🧮 Ошибка 🧮"
        }
        
        calculationHistory.removeAll()
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
        }
        
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    func resetResultLabelText() {
        resultLabel.text = "0"
    }
}
