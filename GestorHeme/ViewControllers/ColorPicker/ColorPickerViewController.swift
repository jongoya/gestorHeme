//
//  ColorPickerViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 12/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import ChromaColorPicker

class ColorPickerViewController: UIViewController {
    @IBOutlet weak var colorPicker: ChromaColorPicker!
    @IBOutlet weak var colorSlider: ChromaBrightnessSlider!
    
    var selectedColor: UIColor!
    var empleado: EmpleadoModel!
    var delegate: ColorPickerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Color"
        colorSlider.connect(to: colorPicker)
        
        addColorHandler()
        addColorChangedHandler()
        
        if delegate == nil {
            addSaveColorButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if delegate != nil  && selectedColor != nil {
            delegate.colorSelected(color: selectedColor)
        }
    }
    
    func addColorHandler() {
        let customHandle = ChromaColorHandle()
        if empleado != nil {
            customHandle.color = UIColor(cgColor: CGColor(srgbRed: CGFloat(empleado.redColorValue), green: CGFloat(empleado.greenColorValue), blue: CGFloat(empleado.blueColorValue), alpha: 1.0))
        } else {
            customHandle.color = .systemBlue
        }
        
        colorPicker.addHandle(customHandle)
    }
    
    func addSaveColorButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(didClickSaveButton))
    }
    
    func addColorChangedHandler() {
        colorSlider.addTarget(self, action: #selector(sliderDidValueChange(_:)), for: .valueChanged)
        colorPicker.delegate = self
    }
}

extension ColorPickerViewController {
    @objc func sliderDidValueChange(_ slider: ChromaBrightnessSlider) {
        selectedColor = slider.currentColor
    }
    
    @objc func didClickSaveButton(sender: UIBarButtonItem) {
        if selectedColor == nil {
            navigationController!.popViewController(animated: true)
            return
        }
        
        let components = selectedColor.cgColor.components
        empleado.redColorValue = Float(components![0])
        empleado.greenColorValue = Float(components![1])
        empleado.blueColorValue = Float(components![2])

        CommonFunctions.showLoadingStateView(descriptionText: "Guardando color")
        
        Constants.cloudDatabaseManager.empleadoManager.updateEmpleado(empleado: empleado, delegate: self)
    }
}

extension ColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        selectedColor = color
    }
}

extension ColorPickerViewController: CloudEmpleadoProtocol {
    func empleadoSincronizationFinished() {
        print("EXITO GUARDANDO COLOR")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            if !Constants.databaseManager.empleadosManager.updateEmpleado(empleado: self.empleado) {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el color, intentelo de nuevo", viewController: self)
                return
            }

            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func empleadoSincronizationError(error: String) {
        print("ERROR GUARDANDO COLOR")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
    func empleadoDeleted(empleado: EmpleadoModel) {
        //NO es necesario implementar
    }
    
}
