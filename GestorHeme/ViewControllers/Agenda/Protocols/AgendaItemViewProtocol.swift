//
//  AgendaItemViewProtocol.swift
//  GestorHeme
//
//  Created by jon mikel on 07/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

protocol AgendaItemViewProtocol {
    func serviceClicked(service: ServiceModel)
    func dayClicked(date: Date)
    func crossButtonClicked(service: ServiceModel)
}
