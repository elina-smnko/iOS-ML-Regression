//
//  ViewController.swift
//  MLProj
//
//  Created by Elina Semenko on 13.07.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var cityPicker: UIPickerView!
    @IBOutlet weak private var titlePicker: UIPickerView!
    @IBOutlet weak private var timePicker: UIPickerView!
    @IBOutlet weak private var salaryLabel: UILabel!
    @IBOutlet weak private var languagePicker: UIPickerView!
    @IBOutlet weak var button: UIButton!
    
    private var city: String = "Київ"
    private var ptitle: String = "Junior"
    private var language: String = "Python"
    private var time: String = "1р"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        cityPicker.dataSource = self
        cityPicker.delegate = self
        
        titlePicker.dataSource = self
        titlePicker.delegate = self
        
        timePicker.dataSource = self
        timePicker.delegate = self
        
        languagePicker.dataSource = self
        languagePicker.delegate = self
        
        
        salaryLabel.textColor = .purple
        button.backgroundColor = .purple
        button.clipsToBounds = true
        button.layer.cornerRadius = 12
    }
    

    @IBAction func getValue(_ sender: Any) {
        let input = MyRegressorInput(city: city, title: ptitle, language: language, time: time)
        
        guard let output = ModelUpdater.predictMoneyFor(input) else {
            print("prediction error")
            return
        }
        print(output)
        salaryLabel.text = "\(Int(output))$"
        
    }
    
    @IBAction func resetModel(_ sender: Any) {
        ModelUpdater.reset()
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPicker {
            return Models.cities.count
        } else if pickerView == timePicker {
            return Models.times.count
        } else if pickerView == languagePicker {
            return Models.languages.count
        } else {
            return Models.titles.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPicker {
            return Models.cities[row]
        } else if pickerView == timePicker {
            return Models.times[row]
        } else if pickerView == languagePicker {
            return Models.languages[row]
        } else {
            return Models.titles[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cityPicker {
            city = Models.cities[row]
        } else if pickerView == timePicker {
            time = Models.times[row]
        } else if pickerView == languagePicker {
            language = Models.languages[row]
        } else {
            ptitle = Models.titles[row]
        }
    }
}

