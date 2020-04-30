//
//  NotificationDetailViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import MessageUI

class NotificationDetailViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var notificationReasonLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    var notification: NotificationModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notificación"
        
        if !notification.leido  {
            markNotificationAsRead()
        }
        
        setContentView()
        customizeButton(button: callButton)
        customizeButton(button: sendEmailButton)
        customizeButton(button: chatButton)
    }
    
    func markNotificationAsRead() {
        notification.leido = true
        CommonFunctions.showLoadingStateView(descriptionText: "Actualizando notificación")
        Constants.cloudDatabaseManager.notificationManager.updateNotification(notification: notification, delegate: self)
    }
    
    func setContentView() {
        if notification.type == Constants.notificacionCumpleIdentifier {
            backgroundImageView.image = UIImage(named: "confetti")
            notificationReasonLabel.text = "¡Cumpleaños!"
            shortDescriptionLabel.text = createBirthdayDescription()
            longDescriptionLabel.text = notification.descripcion
        } else if notification.type == Constants.notificacionPersonalizadaIdentifier {
            backgroundImageView.image = UIImage(named: "personalizada")
            notificationReasonLabel.text = "Notificación personalizada"
            shortDescriptionLabel.text = createNotificacionPersonalizadaDescription()
            longDescriptionLabel.text = notification.descripcion
        }
    }
    
    func customizeButton(button: UIView) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.backgroundColor = .white
    }
    
    func createBirthdayDescription() -> String {
        let users: [Int64] = notification.clientId
        var text: String = ""
        for user in users {
            if let client = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: user) {
                text.append(client.nombre + " " + client.apellidos)
            }
            if let empleado = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: user) {
                text.append(empleado.nombre + " " + empleado.apellidos)
            }
            
            text.append(", ")
        }
        
        return text + (users.count > 1 ? "felicitalos!" : "felicitalo!")
    }
    
    func createNotificacionPersonalizadaDescription() -> String {
        let year: Int = AgendaFunctions.getYearNumberFromDate(date: Date(timeIntervalSince1970: TimeInterval(notification.fecha)))
        let month: String = AgendaFunctions.getMonthNameFromDate(date: Date(timeIntervalSince1970: TimeInterval(notification.fecha))).capitalized
        let day: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(notification.fecha)))
        
        return String(day) + " de " + String(month) + " de " + String(year)
    }
    
    func showActionsheet(comunicationCase: Int) {
        let alert = UIAlertController(title: "Elige", message: "Debe elegir una de las opciones", preferredStyle: .actionSheet)
        for index in 0...notification.clientId.count - 1 {
            alert.addAction(UIAlertAction(title: getNombreApellidosFromUser(userId: notification.clientId[index]), style: .default , handler:{ (UIAlertAction) in
                self.openComunicationForCase(comunicationCase: comunicationCase, userPosition: index)
            }))
        }

        alert.addAction(UIAlertAction(title: "cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func getTelefonoFromUser(userId: Int64) -> String {
        if let client = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: notification.clientId.first!) {
            return client.telefono.replacingOccurrences(of: " ", with: "")
         }
         
         if let empleado = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: notification.clientId.first!) {
            return empleado.telefono.replacingOccurrences(of: " ", with: "")
         }
        
        return " "
    }
    
    func getNombreApellidosFromUser(userId: Int64) -> String {
        if let client = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: userId) {
            return client.nombre + " " + client.apellidos
         }
         
         if let empleado = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: userId) {
            return empleado.nombre + " " + empleado.apellidos
         }
        
        return " "
    }
    
    func composeLetter(telefono: String) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.recipients = [telefono]

        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            CommonFunctions.showGenericAlertMessage(mensaje: "Este dispositivo no puede mandar mensajes", viewController: self)
        }
    }
    
    func openComunicationForCase(comunicationCase: Int, userPosition: Int) {
        switch comunicationCase {
        case 1:
            CommonFunctions.callPhone(telefono: getTelefonoFromUser(userId: notification.clientId[userPosition]))
            break
        case 2:
            composeLetter(telefono: getTelefonoFromUser(userId: notification.clientId[userPosition]))
            break
        default:
            CommonFunctions.openWhatsapp(telefono: getTelefonoFromUser(userId: notification.clientId[userPosition]))
            break
        }
    }
}

extension NotificationDetailViewController {
    @IBAction func didClickCallButton(_ sender: Any) {
        if notification.clientId.count > 1 {
            showActionsheet(comunicationCase: 1)
        } else {
            CommonFunctions.callPhone(telefono: getTelefonoFromUser(userId: notification.clientId.first!))
        }
    }
    
    @IBAction func didClickSendEmailButton(_ sender: Any) {
        if notification.clientId.count > 1 {
            showActionsheet(comunicationCase: 2)
        } else {
            composeLetter(telefono: getTelefonoFromUser(userId: notification.clientId.first!))
        }
    }
    
    @IBAction func didClickChatButton(_ sender: Any) {
        if notification.clientId.count > 1 {
            showActionsheet(comunicationCase: 3)
        } else {
            CommonFunctions.openWhatsapp(telefono: getTelefonoFromUser(userId: notification.clientId.first!))
        }
    }
}

extension NotificationDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension NotificationDetailViewController: CloudNotificationProtocol {
    func notificacionSincronizationFinished() {
        _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            Constants.rootController.setNotificationBarItemBadge()
        }
    }
    
    func notificacionSincronizationError(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando notificación", viewController: self)
        }
    }
}
