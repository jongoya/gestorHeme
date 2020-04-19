//
//  ListSelectorProtocol.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

protocol ListSelectorProtocol {
    func optionSelected(option: Any, inputReference: Int)
    func multiSelectionOptionsSelected(options: [Any], inputReference: Int)
}
