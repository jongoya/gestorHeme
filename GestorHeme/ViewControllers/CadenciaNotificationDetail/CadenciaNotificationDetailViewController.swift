//
//  CadenciaNotificationDetailViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 24/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class CadenciaNotificationDetailViewController: UIViewController {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var cadenciaTextLabel: UILabel!
    @IBOutlet weak var clientTableView: UITableView!
    
    var notification: NotificationModel!
    var clientes: [ClientModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detalle"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getClientes()
        setCadenciaLabel()
        
        if !notification.leido {
            markNotificationAsRead()
        }
    }
    
    func setCadenciaLabel() {
        cadenciaTextLabel.text = notification.clientId.count > 1 ? "Hay " + String(notification.clientId.count) + " clientes que llevan tiémpo sin venir" : "Hay 1 Cliente que lleva tiémpo sin venir"
    }
    
    func getClientes() {
        for clientId: Int64 in notification.clientId {
            clientes.append(Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: clientId)!)
        }
        
        clientTableView.reloadData()
    }
    
    func markNotificationAsRead() {
        notification.leido = true
        _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
        Constants.rootController.setNotificationBarItemBadge()
        
        Constants.cloudDatabaseManager.notificationManager.updateNotification(notification: notification, showLoadingState: true)
    }
}

extension CadenciaNotificationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CadenciaNotificationCell = tableView.dequeueReusableCell(withIdentifier: "CadenciaNotificationCell", for: indexPath) as! CadenciaNotificationCell
        cell.selectionStyle = .none
        cell.setupCell(client: clientes[indexPath.row])
        return cell
    }
}
