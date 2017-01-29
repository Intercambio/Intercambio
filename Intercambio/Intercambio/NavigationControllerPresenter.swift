//
//  NavigationControllerPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
//


import Foundation
import CoreXMPP

class NavigationControllerPresenter : NSObject, NavigationControllerViewEventHandler {
    
    class ViewModel : NavigationControllerStatusViewModel {
        let accountURI: URL
        let title: String
        init(accountURI: URL) {
            self.accountURI = accountURI
            title = "\(accountURI.user ?? "")@\(accountURI.host ?? "")"
        }
    }
    
    let accountManager: AccountManager
    var router: NavigationControllerRouter?
    weak var view: NavigationControllerView? {
        didSet {
            updateStatus()
        }
    }
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        super.init()
        registerNotificationObservers()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    // NavigationControllerViewEventHandler
    
    func didTap(status: NavigationControllerStatusViewModel) {
        if let model = status as? ViewModel {
            router?.presentAccountUserInterface(for: model.accountURI)
        }
    }
    
    // Update Status
    
    private func updateStatus() {
        var status: [ViewModel] = []
        for jid in accountManager.accounts {
            if let info = accountManager.info(for: jid) {
                if info.connectionState != .connected {
                    var components = URLComponents()
                    components.scheme = "xmpp"
                    components.host = jid.host
                    components.user = jid.user
                    if let uri = components.url {
                        status.append(ViewModel(accountURI: uri))
                    }
                }
            }
        }
        view?.status = status
    }
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: AccountManagerDidAddAccount),
                                                        object: accountManager,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.updateStatus()
            })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: AccountManagerDidChangeAccount),
                                                        object: accountManager,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.updateStatus()
            })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: AccountManagerDidRemoveAccount),
                                                        object: accountManager,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.updateStatus()
            })
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers {
            center.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
}
