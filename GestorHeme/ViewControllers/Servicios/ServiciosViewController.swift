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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servicios"
        
        addCreateServicioButton()
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
}
