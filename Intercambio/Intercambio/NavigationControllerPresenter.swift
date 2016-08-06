//
//  NavigationControllerPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
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
