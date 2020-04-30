//
//  CloudClientManagerProtocol.swift
//  GestorHeme
//
//  Created by jon mikel on 29/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

protocol CloudClientManagerProtocol {
    func clientSincronizationFinished()
    func clientSincronizationError(error: String)
}
