//
//  ListSelectorViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ListSelectorViewController: UIViewController {
    @IBOutlet weak var optionsList: UITableView!
    
    var delegate: ListSelectorProtocol!
    var inputReference: Int!
    var listOptions: [Any]!
    var allowMultiselection: Bool!
    var multiSelectionOptions: [Any] = []
    var emptyStateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Elige"
        if allowMultiselection {
            optionsList.allowsMultipleSelection = true
        }
        
        if listOptions.count == 0 {
            emptyStateLabel = CommonFunctions.createEmptyState(emptyText: "No dispone de opciones a elegir, por favor añadelos", parentView: self.view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if allowMultiselection && multiSelectionOptions.count > 0 {
            delegate.multiSelectionOptionsSelected(options: multiSelectionOptions, inputReference: inputReference)
        }
    }
}

extension ListSelectorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListSelectorCell = tableView.dequeueReusableCell(withIdentifier: "ListSelectorCell", for: indexPath) as! ListSelectorCell
        if !allowMultiselection {
            cell.selectionStyle = .none
        }
        
        cell.setupCell(option: CommonFunctions.getStringOptionForListSelectorCell(row: indexPath.row, array: listOptions))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !allowMultiselection {
            delegate.optionSelected(option: listOptions[indexPath.row], inputReference: inputReference)
            self.navigationController!.popViewController(animated: true)
        } else {
            multiSelectionOptions.append(listOptions[indexPath.row] as! TipoServicioModel)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !allowMultiselection {
            return
        }
        
        var position: Int = -1
        for index in 0...multiSelectionOptions.count - 1 {
            if CommonFunctions.getIdentiferForListSelectorCell(row: index, array: multiSelectionOptions) == CommonFunctions.getIdentiferForListSelectorCell(row: indexPath.row, array: listOptions) {
                position = index
            }
        }
        
        if position != -1 {
            multiSelectionOptions.remove(at: position)
        }
    }
}

