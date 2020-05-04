//
//  ServicioView.swift
//  GestorHeme
//
//  Created by jon mikel on 03/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ServicioView: UIView {
    let defaultMargin: CGFloat = 10
    let fieldWidth: CGFloat = 135
    let fieldHeigth: CGFloat = 50
    let observacionesTopMargin: CGFloat = 20
    
    var titleLabel: UILabel = UILabel()
    let observacionesLabel: UILabel = UILabel()
    
    var servicio: ServiceModel!
    var fieldArray: [UIView] = []
    var delegate: ServicioViewProtocol!
    
    init(service: ServiceModel) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        servicio = service
        
        addGestureRecognizer()
        createContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addGestureRecognizer() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(servicioClicked(_:))))
    }
    
    func createContent() {
        customizeView()
        
        addTitle()
        
        addFieldForServiceField(serviceField: "Nombre y Apellidos", serviceValue: servicio.nombre + " " + servicio.apellidos)
        addFieldForServiceField(serviceField: "Fecha", serviceValue: CommonFunctions.getDateAndTimeTypeStringFromDate(date: Date(timeIntervalSince1970: TimeInterval(servicio.fecha))))
        addFieldForServiceField(serviceField: "Profesional", serviceValue: Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: servicio.profesional)!.nombre)
        addFieldForServiceField(serviceField: "Servicio", serviceValue: CommonFunctions.getServiciosStringFromServiciosArray(servicios: servicio.servicio))
        addFieldForServiceField(serviceField: "Precio", serviceValue: String(format: "%.2f", servicio.precio) + " €")
        
        addObservacionView()
        
        setContentContraints()
    }
    
    func customizeView() {
        layer.cornerRadius = 15
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        backgroundColor = .white
    }
    
    func addTitle() {
        titleLabel.frame = .zero
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "SERVICIO"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .black
        addSubview(titleLabel)
    }
    
    func addFieldForServiceField(serviceField: String, serviceValue: String) {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        addSubview(view)
        
        let serviceFieldLabel: UILabel = UILabel()
        serviceFieldLabel.translatesAutoresizingMaskIntoConstraints = false
        serviceFieldLabel.text = serviceField
        serviceFieldLabel.textColor = .black
        serviceFieldLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.addSubview(serviceFieldLabel)
        
        let serviceValueLabel: UILabel = UILabel()
        serviceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        serviceValueLabel.text = serviceValue
        serviceValueLabel.textColor = .gray
        serviceValueLabel.textAlignment = .right
        serviceValueLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.addSubview(serviceValueLabel)
        
        let divisory: UIView = UIView()
        divisory.translatesAutoresizingMaskIntoConstraints = false
        divisory.backgroundColor = .systemGray4
        view.addSubview(divisory)
        
        fieldArray.append(view)
        
        view.heightAnchor.constraint(equalToConstant: fieldHeigth).isActive = true
        
        serviceFieldLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        serviceFieldLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        serviceFieldLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: defaultMargin).isActive = true
        serviceFieldLabel.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        
        serviceValueLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        serviceValueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        serviceValueLabel.leadingAnchor.constraint(equalTo: serviceFieldLabel.trailingAnchor, constant: defaultMargin).isActive = true
        serviceValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -defaultMargin).isActive = true
        
        divisory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: defaultMargin).isActive = true
        divisory.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        divisory.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        divisory.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func addObservacionView() {
        let observacionText: String = servicio.observacion.count > 0 ? servicio.observacion : "Añade una observación"
        observacionesLabel.translatesAutoresizingMaskIntoConstraints = false
        observacionesLabel.text = observacionText
        observacionesLabel.numberOfLines = 100
        observacionesLabel.textColor = .black
        observacionesLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        addSubview(observacionesLabel)
    }
    
    func setContentContraints() {
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: defaultMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        var previousView: UIView!
        for view: UIView in fieldArray {
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: previousView != nil ? previousView.bottomAnchor: titleLabel.bottomAnchor, constant: previousView != nil ? 0 : defaultMargin).isActive = true
            previousView = view
        }
        
        observacionesLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: defaultMargin).isActive = true
        observacionesLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -defaultMargin).isActive = true
        observacionesLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        observacionesLabel.topAnchor.constraint(equalTo: fieldArray.last!.bottomAnchor, constant: observacionesTopMargin).isActive = true
    }
}

extension ServicioView {
    @objc func servicioClicked(_ sender: UITapGestureRecognizer? = nil) {
        if delegate != nil {
            delegate.servicioClicked(service: servicio)
        }
    }
}
