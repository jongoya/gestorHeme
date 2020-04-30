//
//  ServiciosViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 13/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ServiciosViewController: UIViewController {
    @IBOutlet weak var serviciosTableView: UITableView!
    
    var emptyStateLabel: UILabel!
    
    var servicios: [TipoServicioModel] = []
    var tableRefreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servicios"
        
        addCreateServicioButton()
        addRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showServicios()
    }
    
    func showServicios() {
        if emptyStateLabel != nil {
            emptyStateLabel.removeFromSuperview()
            emptyStateLabel = nil
        }
        
        servicios = Constants.databaseManager.tipoServiciosManager.getAllServiciosFromDatabase()
        
        if servicios.count > 0 {
            serviciosTableView.reloadData()
        } else {
            emptyStateLabel = CommonFunctions.createEmptyState(emptyText: "No dispone de servicios", parentView: self.view)
        }
        
    }
    
    func addCreateServicioButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(didClickCreateServicioButton))
    }
    
    func addRefreshControl() {
        tableRefreshControl.addTarget(self, action: #selector(refreshServicios(_:)), for: .valueChanged)
        serviciosTableView.refreshControl = tableRefreshControl
    }
}

extension ServiciosViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servicios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ServicioTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ServicioTableViewCell", for: indexPath) as! ServicioTableViewCell
        cell.selectionStyle = .none
        cell.setupCell(servicio: servicios[indexPath.row])
        return cell
    }
}

extension ServiciosViewController {
    @objc func didClickCreateServicioButton(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddServicioIdentifier", sender: nil)
    }
    
    @objc func refreshServicios(_ sender: Any) {
        Constants.cloudDatabaseManager.tipoServicioManager.getTipoServicios(delegate: self)
    }
}

extension ServiciosViewController: CloudTipoServiciosProtocol {
    func tipoServiciosSincronizationFinished() {
        print("EXITO CARGANDO TIPO SERVICIOS")
        DispatchQueue.main.async {
            self.tableRefreshControl.endRefreshing()
            self.showServicios()
        }
    }
    
    func tipoServiciosSincronizationError(error: String) {
        print("ERROR CARGANDO TIPO SERVICIOS")
        DispatchQueue.main.async {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error cargando servicios", viewController: self)
        }
    }
}
