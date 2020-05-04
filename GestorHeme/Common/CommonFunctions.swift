//
//  CommonFunctions.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation
import UIKit

class CommonFunctions: NSObject {
    static var servicesLoadingStateView: UIView!
    
    static func getTimeTypeStringFromDate(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "dd/MMMM/yyyy"
        return df.string(from: date)
    }
        
    static func getDateAndTimeTypeStringFromDate(date: Date) -> String {
         let df = DateFormatter()
         df.locale = Locale(identifier: "es_ES")
         df.dateFormat = "dd/MMMM/yyyy HH:mm"
         return df.string(from: date)
     }
    
    static func getMonthFromDate(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "MMMM"
        return df.string(from: date)
    }
    
    static func getYearFromDate(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "yyyy"
        return df.string(from: date)
    }
        
    static func getProfessionalList() -> [EmpleadoModel] {
        return Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase()
    }
        
    static func getServiceList() -> [TipoServicioModel] {
        return Constants.databaseManager.tipoServiciosManager.getAllServiciosFromDatabase()
    }

    static func showGenericAlertMessage(mensaje: String, viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    static func customizeButton(button: UIView) {
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.borderWidth = 1
    }
    
    static func getClientsTableIndexValues() -> [String] {
        return ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "Vacio"]
    }
    
    static func getNumberOfYearsBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: startDate, to: endDate)
        return components.year!
    }

    static func getIdentiferForListSelectorCell(row: Int, array: [Any]) -> Int64 {
        if let profesional: EmpleadoModel = array[row] as? EmpleadoModel {
            return profesional.empleadoId
        }
        
        if let servicio: TipoServicioModel = array[row] as? TipoServicioModel {
            return servicio.servicioId
        }
        
        return 0
    }
    
    static func getStringOptionForListSelectorCell(row: Int, array: [Any]) -> String {
        if let profesional: EmpleadoModel = array[row] as? EmpleadoModel {
            return profesional.nombre
        }
        
        if let servicio: TipoServicioModel = array[row] as? TipoServicioModel {
            return servicio.nombre
        }
        
        return ""
    }
    
    static func getServiciosIdentifiers(servicios: [TipoServicioModel]) -> [Int64] {
        var identifiers: [Int64] = []
        for servicio: TipoServicioModel in servicios {
            identifiers.append(servicio.servicioId)
        }
        
        return identifiers
    }
    
    static func getServiciosString(servicios: [TipoServicioModel]) -> String {
        var stringServicio: String = ""
        for servicio: TipoServicioModel in servicios {
            stringServicio.append(servicio.nombre + ", ")
        }
        
        return stringServicio
    }
    
    static func getServiciosStringFromServiciosArray(servicios: [Int64]) -> String {
        var servicioString: String = ""
        
        for servicioId in servicios {
            servicioString.append(Constants.databaseManager.tipoServiciosManager.getTipoServicioFromDatabase(servicioId: servicioId).nombre + ", ")
        }
        
        return servicioString
    }
    
    static func createEmptyState(emptyText: String, parentView: UIView) -> UILabel {
        let emptyState: UILabel = UILabel()
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyState.text = emptyText
        emptyState.textColor = .black
        emptyState.font = UIFont.systemFont(ofSize: 15)
        emptyState.textAlignment = .center
        emptyState.numberOfLines = 5
        parentView.addSubview(emptyState)
        
        emptyState.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 15).isActive = true
        emptyState.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 15).isActive = true
        emptyState.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -15).isActive = true
        emptyState.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -15).isActive = true
        
        return emptyState
    }
    
    static func showLoadingStateView(descriptionText: String) {
        DispatchQueue.main.async {
            addLoadingStateView(descriptionText: descriptionText)
        }
    }
    
    static func hideLoadingStateView() {
        DispatchQueue.main.async {
            if servicesLoadingStateView != nil {
                servicesLoadingStateView.removeFromSuperview()
                servicesLoadingStateView =  nil
            }
        }
    }
    
    static func getRootViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    static private func addLoadingStateView(descriptionText: String) {
        if servicesLoadingStateView != nil {
            hideLoadingStateView()
        }
        
        let viewController = getRootViewController()

        servicesLoadingStateView = UIView()
        servicesLoadingStateView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(servicesLoadingStateView)
        
        let alphaView: UIView = UIView()
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        alphaView.backgroundColor = .black
        alphaView.alpha = 0.6
        servicesLoadingStateView.addSubview(alphaView)
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        servicesLoadingStateView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 15)
        servicesLoadingStateView.addSubview(descriptionLabel)
        
        servicesLoadingStateView.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
        servicesLoadingStateView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
        servicesLoadingStateView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
        servicesLoadingStateView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
        
        alphaView.topAnchor.constraint(equalTo: servicesLoadingStateView.topAnchor).isActive = true
        alphaView.leadingAnchor.constraint(equalTo: servicesLoadingStateView.leadingAnchor).isActive = true
        alphaView.trailingAnchor.constraint(equalTo: servicesLoadingStateView.trailingAnchor).isActive = true
        alphaView.bottomAnchor.constraint(equalTo: servicesLoadingStateView.bottomAnchor).isActive = true
        
        activityIndicator.centerYAnchor.constraint(equalTo: servicesLoadingStateView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: servicesLoadingStateView.centerXAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 30).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: servicesLoadingStateView.leadingAnchor, constant: 15).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: servicesLoadingStateView.trailingAnchor, constant: -15).isActive = true
    }
    
    static func callPhone(telefono: String) {
        if let url = NSURL(string: "tel://\(telefono)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            DispatchQueue.main.async {
                CommonFunctions.showGenericAlertMessage(mensaje: "Este dispositivo no puede realizar llamadas", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
    
    static func openWhatsapp(telefono: String) {
        let urlWhats = "whatsapp://send?phone=" + telefono + "&text="
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(whatsappURL)
                    }
                } else {
                    DispatchQueue.main.async {
                        CommonFunctions.showGenericAlertMessage(mensaje: "Error abriendo Whatsapp", viewController: CommonFunctions.getRootViewController())
                    }
                }
            }
        }
    }
    
    static func getCadenciasArray() -> [CadenciaModel] {
        return [CadenciaModel(cadencia: Constants.unaSemana), CadenciaModel(cadencia: Constants.dosSemanas), CadenciaModel(cadencia: Constants.tresSemanas), CadenciaModel(cadencia: Constants.unMes), CadenciaModel(cadencia: Constants.unMesUnaSemana), CadenciaModel(cadencia: Constants.unMesDosSemanas), CadenciaModel(cadencia: Constants.unMesTresSemanas), CadenciaModel(cadencia: Constants.dosMeses), CadenciaModel(cadencia: Constants.dosMesesYUnaSemana), CadenciaModel(cadencia: Constants.dosMesesYDosSemanas), CadenciaModel(cadencia: Constants.dosMesesYTresSemanas), CadenciaModel(cadencia: Constants.tresMeses), CadenciaModel(cadencia: Constants.masDeTresMeses)]
    }
    
    static func sincronizarBaseDeDatos() {
        Constants.cloudDatabaseManager.empleadoManager.getEmpleados(delegate: nil)
        Constants.cloudDatabaseManager.tipoServicioManager.getTipoServicios(delegate: nil)
        Constants.cloudDatabaseManager.notificationManager.getNotificaciones(delegate: nil)
        Constants.cloudDatabaseManager.serviceManager.getServicios()
        Constants.cloudDatabaseManager.cierreCajaManager.getCierreCajas()
    }
    
    static func checkBackupState() {
        if !UserPreferences.checkValueInUserDefaults(key: Constants.backupKey) {
            UserPreferences.saveValueInUserDefaults(value: Int64(Date().timeIntervalSince1970), key: Constants.backupKey)
            return
        }
        
        let backupTimeStamp: Int64 = UserPreferences.getValueFromUserDefaults(key: Constants.backupKey) as! Int64
        let fechaTimeStamp: Int64 = Int64(Calendar.current.date(byAdding: .day, value: -7, to: Date())!.timeIntervalSince1970)
        
        if backupTimeStamp < fechaTimeStamp {
            BackupManager.buildBackupJson()
        }
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
