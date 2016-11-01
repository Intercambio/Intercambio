//
//  ContactPickerView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

protocol ContactPickerView : class {
    var selectedAccount: ContactPickerAddress? { get set }
    var accounts: [ContactPickerAddress]? { get set }
}
