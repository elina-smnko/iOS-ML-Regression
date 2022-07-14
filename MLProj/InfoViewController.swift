//
//  InfoViewController.swift
//  MLProj
//
//  Created by Elina Semenko on 13.07.2022.
//

import UIKit
import CoreML

class InfoViewController: UIViewController {

    @IBOutlet weak private var cityPicker: UIPickerView!
    @IBOutlet weak private var titlePicker: UIPickerView!
    @IBOutlet weak private var timePicker: UIPickerView!
    @IBOutlet weak private var languagePicker: UIPickerView!
    @IBOutlet weak private var moneyField: UITextField!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private var city: String = "Київ"
    private var ptitle: String = "Junior"
    private var language: String = "Python"
    private var time: String = "1р"
    private var money = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupNotifications()
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
        
        self.hideKeyboardWhenTappedAround()
        salaryLabel.text = "Salary:"
        salaryLabel.textColor = .black
        
        moneyField.backgroundColor = .white
        moneyField.textColor = .purple
        button.backgroundColor = .purple
        button.clipsToBounds = true
        button.layer.cornerRadius = 12
        
        addDoneButtonOnKeyboard()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func addDoneButtonOnKeyboard()
        {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            moneyField.inputAccessoryView = doneToolbar
        }

        @objc func doneButtonAction()
        {
            moneyField.resignFirstResponder()
        }
    
    @IBAction func addInfo(_ sender: Any) {
        guard let text = moneyField.text, !text.isEmpty else {
            salaryLabel.text = "ENTER STH"
            salaryLabel.textColor = .red
            return
        }
        salaryLabel.text = "Salary:"
        salaryLabel.textColor = .black
        guard let double = Double(text) else { return }
        money = double
        
        ModelUpdater.updateWith(input: UpdateInput(city: city, title: ptitle, language: language, time: time, money: money))
    }
}

extension InfoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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


