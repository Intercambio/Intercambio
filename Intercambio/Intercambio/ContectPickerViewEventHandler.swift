//
//  ContectPickerViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol ContectPickerViewEventHandler : class {
    func didSelectAccount(_ account: ContactPickerAddress?)
    func addressFor(_ text: String) -> ContactPickerAddress?
    func didRemove(_ address: ContactPickerAddress)
    func didAdd(_ address: ContactPickerAddress)
}
