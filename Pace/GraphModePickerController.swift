//
//  GraphModePickerController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 7/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class GraphModePickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet private var picker: UIPickerView!
//    private var pickerOptions = GraphComparisonMode.AllCases.map { mode in String(mode) }

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
