//
//  ListaClientesViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 31/03/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ListaClientesViewController: UIViewController {
    @IBOutlet weak var clientesTextField: UITextField!
    @IBOutlet weak var clientsTableView: UITableView!
    
    var filteredClients: [[ClientModel]] = []
    var arrayIndexSection: [String]!
    var filteredArrayIndexSection: [String] = []
    var emptyStateLabel: UILabel!
    var tableRefreshControl: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldProperties()
        arrayIndexSection = CommonFunctions.getClientsTableIndexValues()
        
        addRefreshControl()
        
        refreshClients()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getClients()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func setTextFieldProperties() {
        clientesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        clientesTextField.returnKeyType = .done
        clientesTextField.delegate = self
    }
    
    func getClients() {
        if emptyStateLabel != nil {
            emptyStateLabel.removeFromSuperview()
            emptyStateLabel = nil
        }
        
        var allClientes: [ClientModel] = Constants.databaseManager.clientsManager.getAllClientsFromDatabase()
        
        if clientesTextField.text!.count != 0 {
            allClientes = Constants.databaseManager.clientsManager.getClientsFilteredByText(text: clientesTextField.text!)
        }
        
        if allClientes.count > 0 {
            indexClients(arrayClients: allClientes)
            clientsTableView.reloadData()
        } else {
            emptyStateLabel = CommonFunctions.createEmptyState(emptyText: "No dispone de clientes, clique en el botón + para añadir un cliente", parentView: self.view)
        }
    }
    
    func indexClients(arrayClients: [ClientModel]) {
        var indexedArray: [[ClientModel]] = []
        filteredArrayIndexSection = []
        for index: String in arrayIndexSection {
            var indexArray: [ClientModel] = []
            for client in arrayClients {
                if index == "Vacio" {
                    if client.apellidos == "" {
                        indexArray.append(client)
                    }
                } else {
                    if client.apellidos.lowercased().starts(with: index.lowercased()) {
                        indexArray.append(client)
                    }
                }
            }

            if indexArray.count > 0 {
                indexArray.sort(by: { $0.nombre < $1.nombre })
                indexedArray.append(indexArray)
                filteredArrayIndexSection.append(index)
            }
        }
        
        filteredClients = indexedArray
    }
    
    func addRefreshControl() {
        tableRefreshControl.addTarget(self, action: #selector(refreshClients), for: .valueChanged)
        clientsTableView.refreshControl = tableRefreshControl
    }
}

extension ListaClientesViewController {
    @IBAction func didClickclearTextField(_ sender: Any) {
        clientesTextField.text = ""
        getClients()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.count == 0 {
            getClients()
            return
        }
        
        let clients: [ClientModel] = Constants.databaseManager.clientsManager.getClientsFilteredByText(text: textField.text!)
        indexClients(arrayClients: clients)
        clientsTableView.reloadData()
    }
    
    @objc func refreshClients() {
        Constants.cloudDatabaseManager.clientManager.getClients(delegate: self)
    }
}

extension ListaClientesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        filteredClients.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredClients[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredArrayIndexSection[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ClientCell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! ClientCell
        cell.setupCell(client: filteredClients[indexPath.section][indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ClientDetailIdentifier", sender: filteredClients[indexPath.section][indexPath.row])
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return filteredArrayIndexSection
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

extension ListaClientesViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClientDetailIdentifier" {
            let controller: ClientDetailViewController = segue.destination as! ClientDetailViewController
            controller.client = (sender as! ClientModel)
        }
    }
}

extension ListaClientesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension ListaClientesViewController: CloudClientManagerProtocol {
    func clientSincronizationFinished() {
        DispatchQueue.main.async {
            print("EXITO CARGANDO CLIENTES")
            self.tableRefreshControl.endRefreshing()
            self.getClients()
        }
    }
    
    func clientSincronizationError(error: String) {
        DispatchQueue.main.async {
            self.tableRefreshControl.endRefreshing()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}
