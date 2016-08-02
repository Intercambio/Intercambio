//
//  AccountListView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain

protocol AccountListView : class {
    var dataSource: FTDataSource? { get set }
}
