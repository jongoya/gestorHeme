//
//  PickerSelectorViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 17/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class PickerSelectorViewController: UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    
    var options: [CadenciaModel] = CommonFunctions.getCadenciasArray()
    var delegate: PickerSelectorProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate.cadenciaSelected(cadencia: options[pickerView.selectedRow(inComponent: 0)].cadencia)
    }
}

extension PickerSelectorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].cadencia
    }
}
