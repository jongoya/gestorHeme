//
//  AgendaClientItemView.swift
//  GestorHeme
//
//  Created by jon mikel on 08/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AgendaClientItemView: UIView {
    
    var imageCliente: UIImageView!
    var nombreCliente: UILabel!
    var horaServicio: UILabel!
    
    var cliente: ClientModel!
    var delegate: ClientItemViewProtocol!
    var presentDate:Date!

    init(cliente: ClientModel, presentDate: Date, delegate: ClientItemViewProtocol) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clientClicked(_:))))
        self.cliente = cliente
        self.delegate = delegate
        self.presentDate = presentDate
        customizeContentView()
        
        createContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func customizeContentView() {
        layer.cornerRadius = 10
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
    }
    
    func createContent() {
        addImageView()
        
        addNombreCliente()
        
        addHoraServicio()
        
        setConstraints()
    }
    
    func addImageView() {
        imageCliente = UIImageView()
        imageCliente.translatesAutoresizingMaskIntoConstraints = false
        imageCliente.image = UIImage(named: "user_placeholder")
        addSubview(imageCliente)
    }
    
    func addNombreCliente() {
        nombreCliente = UILabel()
        nombreCliente.translatesAutoresizingMaskIntoConstraints = false
        nombreCliente.text = cliente.nombre + " " + cliente.apellidos
        nombreCliente.textColor = .black
        nombreCliente.font = .systemFont(ofSize: 16, weight: .semibold)
        addSubview(nombreCliente)
    }
    
    func addHoraServicio() {
        horaServicio = UILabel()
        horaServicio.translatesAutoresizingMaskIntoConstraints = false
        horaServicio.text = "Servicios: " + collectHorasCliente()
        horaServicio.textColor = .systemGray3
        horaServicio.font = UIFont.systemFont(ofSize: 14)
        addSubview(horaServicio)
    }
    
    func collectHorasCliente() -> String {
        var services: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: cliente.id)
        services = filterServicesForDay(services: services)
        var arrayHoras: [String] = []
        
        for service in services {
            let fecha: String = AgendaFunctions.getHoursAndMinutesFromDate(date: Date(timeIntervalSince1970: TimeInterval(service.fecha)))
            if !arrayHoras.contains(fecha) {
                arrayHoras.append(fecha)
            }
        }
        
        return arrayHoras.joined(separator: ", ")
    }
    
    func filterServicesForDay(services: [ServiceModel]) -> [ServiceModel] {
        if services.count == 0 {
            return []
        }
        
        let beginingOfDay: Int64 = Int64(AgendaFunctions.getBeginningOfDayFromDate(date: presentDate).timeIntervalSince1970)
        let endOfDay: Int64 = Int64(AgendaFunctions.getEndOfDayFromDate(date: presentDate).timeIntervalSince1970)
        var todayServices: [ServiceModel] = []
        
        for service in services {
            if service.fecha > beginingOfDay && service.fecha < endOfDay {
                todayServices.append(service)
            }
        }
        
        return todayServices
    }
    
    func setConstraints() {
        imageCliente.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageCliente.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageCliente.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageCliente.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        
        nombreCliente.leadingAnchor.constraint(equalTo: imageCliente.trailingAnchor, constant: 10).isActive = true
        nombreCliente.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nombreCliente.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        horaServicio.topAnchor.constraint(equalTo: nombreCliente.bottomAnchor, constant: 5).isActive = true
        horaServicio.leadingAnchor.constraint(equalTo: nombreCliente.leadingAnchor).isActive = true
        horaServicio.trailingAnchor.constraint(equalTo: nombreCliente.trailingAnchor).isActive = true
    }
}

extension AgendaClientItemView {
    @objc func clientClicked(_ sender: UITapGestureRecognizer) {
        delegate.clientClicked(client: cliente)
    }
}
