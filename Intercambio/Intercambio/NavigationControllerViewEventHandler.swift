//
//  NavigationControllerViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol NavigationControllerViewEventHandler : class {
    func didTap(status: NavigationControllerStatusViewModel)
}
