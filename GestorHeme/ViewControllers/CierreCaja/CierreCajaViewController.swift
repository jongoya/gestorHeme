//
//  CierreCajaViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 21/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class CierreCajaViewController: UIViewController {
    @IBOutlet weak var numeroServiciosLabel: UILabel!
    @IBOutlet weak var totalCajaLabel: UILabel!
    @IBOutlet weak var totalProductosLabel: UILabel!
    @IBOutlet weak var efectivoLabel: UILabel!
    @IBOutlet weak var tarjetaLabel: UILabel!
    
    let cierreCaja: CierreCajaModel = CierreCajaModel()
    var presentDate: Date!
    var notification: NotificationModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cierre Caja"
        
        addSaveCierreCajaButton()
        
        fillFields()
    }
    
    func addSaveCierreCajaButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(didClickSaveCierreCajaButton))
    }
    
    func fillFields() {
        let services: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForDay(date: presentDate)
        numeroServiciosLabel.text = String(services.count)
        totalCajaLabel.text = String(format: "%.2f", getTotalCajaFromServicios(servicios: services)) + " €"
        cierreCaja.numeroServicios = services.count
        cierreCaja.totalCaja = getTotalCajaFromServicios(servicios: services)
    }
    
    func getTotalCajaFromServicios(servicios: [ServiceModel]) -> Double {
        var totalCaja: Double = 0.0
        for servicio: ServiceModel in servicios {
            totalCaja = totalCaja + servicio.precio
        }
        
        return totalCaja
    }
    
    func getKeyboardTypeForField(inputReference: Int) -> UIKeyboardType {
        switch inputReference {
        case 1:
            return .numberPad
        default:
            return .decimalPad
        }
    }
    func getInputTextForField(inputReference: Int) -> String {
        switch inputReference {
        case 1:
            return numeroServiciosLabel.text!
        case 2:
            return totalCajaLabel.text!
        case 3:
            return totalProductosLabel.text!
        case 4:
            return efectivoLabel.text!
        default:
            return tarjetaLabel.text!
        }
    }
    
    func getControllerTitleForField(inputReference: Int) -> String {
        switch inputReference {
        case 1:
            return "Número servicios"
        case 2:
            return "Total caja"
        case 3:
            return "Total productos"
        case 4:
            return "Efectivo"
        default:
            return "Tarjeta"
        }
    }
    
    func checkFields() {
        if numeroServiciosLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluier un numero de servicios", viewController: self)
            return
        }
        
        if totalCajaLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un total en la caja", viewController: self)
            return
        }
        
        if totalProductosLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un total de productos", viewController: self)
            return
        }
        
        if efectivoLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un total en efectivo", viewController: self)
            return
        }
        
        if tarjetaLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un total en tarjeta", viewController: self)
            return
        }
        
        saveCierreCaja()
    }
    
    func saveCierreCaja() {
        cierreCaja.cajaId = Int64(Date().timeIntervalSince1970)
        cierreCaja.fecha = Int64(presentDate.timeIntervalSince1970)
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando el cierre de caja")
        Constants.cloudDatabaseManager.cierreCajaManager.saveCierreCaja(cierreCaja: cierreCaja, delegate: self)
    }
}

extension CierreCajaViewController {
    @objc func didClickSaveCierreCajaButton(sender: UIBarButtonItem) {
        checkFields()
    }
    
    @IBAction func didClickNumeroServicios(_ sender: Any) {
        performSegue(withIdentifier: "inputFieldIdentifier", sender: 1)
    }
    
    @IBAction func didClickTotalCaja(_ sender: Any) {
        performSegue(withIdentifier: "inputFieldIdentifier", sender: 2)
    }
    
    @IBAction func didClickTotalProductos(_ sender: Any) {
        performSegue(withIdentifier: "inputFieldIdentifier", sender: 3)
    }
    
    @IBAction func didClickEfectivo(_ sender: Any) {
        performSegue(withIdentifier: "inputFieldIdentifier", sender: 4)
    }
    
    @IBAction func didClickTarjeta(_ sender: Any) {
        performSegue(withIdentifier: "inputFieldIdentifier", sender: 5)
    }
}

extension CierreCajaViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inputFieldIdentifier" {
            let controller: FieldViewController = segue.destination as! FieldViewController
            controller.inputReference = (sender as! Int)
            controller.delegate = self
            controller.keyboardType = getKeyboardTypeForField(inputReference: (sender as! Int))
            controller.inputText = getInputTextForField(inputReference: (sender as! Int))
            controller.title = getControllerTitleForField(inputReference: (sender as! Int))
        }
    }
}

extension CierreCajaViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        let value = text.replacingOccurrences(of: ",", with: ".")
        switch inputReference {
        case 1:
            numeroServiciosLabel.text = text
            cierreCaja.numeroServicios = (text as NSString).integerValue
        case 2:
            totalCajaLabel.text = value
            cierreCaja.totalCaja = (value as NSString).doubleValue
        case 3:
            totalProductosLabel.text = value
            cierreCaja.totalProductos = (value as NSString).doubleValue
        case 4:
            efectivoLabel.text = value
            cierreCaja.efectivo = (value as NSString).doubleValue
        default:
            tarjetaLabel.text = value
            cierreCaja.tarjeta = (value as NSString).doubleValue
        }
    }
}

extension CierreCajaViewController: CloudCierreCajaProtocol {
    func cierreCajaSaved() {
        if notification == nil {
            print("EXITO GUARDANDO EL CIERRE DE CAJA")
            _ = Constants.databaseManager.cierreCajaManager.addCierreCajaToDatabase(newCierreCaja: cierreCaja)
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                self.navigationController!.popViewController(animated: true)
            }
        } else {
            notification.leido = true
            Constants.cloudDatabaseManager.notificationManager.updateNotification(notification: notification, delegate: self)
        }
    }
    
    func errorSavingCierreCaja() {
        print("ERROR GUARDANDO EL CIERRE DE CAJA")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el cierre de caja", viewController: self)
        }
    }
}

extension CierreCajaViewController: CloudNotificationProtocol {
    func notificacionSincronizationFinished() {
        _ = Constants.databaseManager.cierreCajaManager.addCierreCajaToDatabase(newCierreCaja: cierreCaja)
        _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
        DispatchQueue.main.async {
            print("EXITO GUARDANDO EL CIERRE DE CAJA")
            CommonFunctions.hideLoadingStateView()
            Constants.rootController.setNotificationBarItemBadge()
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func notificacionSincronizationError(error: String) {
        DispatchQueue.main.async {
            print("ERROR GUARDANDO EL CIERRE DE CAJA")
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el cierre de caja", viewController: self)
        }
    }
    
    
}
