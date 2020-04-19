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
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    var notification: NotificationModel!
    var client: ClientModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: notification.clientId)!
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
        _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
        Constants.rootController.setNotificationBarItemBadge()
        
        Constants.cloudDatabaseManager.notificationManager.updateNotification(notification: notification)
    }
    
    func setContentView() {
        if notification.type == Constants.notificacionCumpleIdentifier {
            backgroundImageView.image = UIImage(named: "confetti")
            notificationReasonLabel.text = "¡Cumpleaños!"
            name.text = client.nombre + " " + client.apellidos
            shortDescriptionLabel.text = "¡Hoy cumple " + String(CommonFunctions.getNumberOfYearsBetweenDates(startDate: Date(timeIntervalSince1970: TimeInterval(client.fecha)), endDate: Date())) + " años"
            longDescriptionLabel.text = notification.descripcion
        }
    }
    
    func customizeButton(button: UIView) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.backgroundColor = .white
    }
}

extension NotificationDetailViewController {
    @IBAction func didClickCallButton(_ sender: Any) {
        CommonFunctions.callPhone(telefono: client.telefono.replacingOccurrences(of: " ", with: ""))
    }
    
    @IBAction func didClickSendEmailButton(_ sender: Any) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.recipients = [client.telefono]

        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            CommonFunctions.showGenericAlertMessage(mensaje: "Este dispositivo no puede mandar mensajes", viewController: self)
        }
    }
    
    @IBAction func didClickChatButton(_ sender: Any) {
        CommonFunctions.openWhatsapp(telefono: client.telefono)
    }
}

extension NotificationDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
