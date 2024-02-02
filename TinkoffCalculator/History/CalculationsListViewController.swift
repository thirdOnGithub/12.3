//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Булат Камалетдинов on 27.01.2024.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    var dateLabel = UILabel()
    var calculations: [(expression: [CalculationHistoryItem], result: Double)] = []
    @IBOutlet weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = UIColor.systemGray5
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
        
        updateDate()
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateLabel.text
    }
    
    private func expressionToString(_ expression: [CalculationHistoryItem]) -> String {
        var result = ""
        
        for operand in expression {
            switch operand {
            case let .number(value):
                result += String(value) + " "
                
            case let .operation(value):
                result += value.rawValue + " "
            }
        }
        return result
    }
    
    func updateDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: Date())
        dateLabel.text = currentDate
    }
}

extension CalculationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

extension CalculationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        let historyItem = calculations[indexPath.row]
        cell.configure(with: expressionToString(historyItem.expression), result: String(historyItem.result))
        return cell
    }
}
