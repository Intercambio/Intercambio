//
//  AccountProfilePresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

class AccountProfilePresenter: AccountProfileViewEventHandler {
    
    deinit {
        disableNextConnectionAttemptTimer()
    }
    
    weak var view: AccountProfileView? {
        didSet {
            updateView()
        }
    }
    
    var interactor: AccountProfileProvider? {
        willSet {
            let center = NotificationCenter.default
            center.removeObserver(self, name: AccountProfileProviderDidUpdateAccount, object: nil)
        }
        didSet {
            let center = NotificationCenter.default
            center.addObserver(self, selector: #selector(updateView), name: AccountProfileProviderDidUpdateAccount, object: interactor)
            updateView()
        }
    }
    
    var router: AccountProfileRouter?
    
    func connectAccount() {
        if let interactor = self.interactor {
            do {
                try interactor.connect()
            } catch {
                
            }
        }
    }
    
    func showAccountSettings() {
        if let router = self.router,
            let uri = self.interactor?.accountURI {
            router.presentSettingsUserInterface(for: uri)
        }
    }
    
    // Update View
    
    @objc private func updateView() {
        let account = interactor?.account
        
        if account?.nextConnectionAttempt != nil {
            enableNextConnectionAttemptTimer()
        } else {
            disableNextConnectionAttemptTimer()
        }
        
        view?.isProfileHidden = account == nil
        
        view?.name = account?.name
        view?.details = account != nil ? connectionStateLabel(for: account!) : nil
        view?.nextAction = account != nil ? nextConnectionLabel(for: account!) : nil
        view?.errorMessage = account != nil ? errorMessageLabel(for: account!) : nil
        view?.connectionButtonEnabled = account != nil ? account!.state == .disconnected : false
        view?.connectionButtonHidden = account != nil ? account!.state == .connected || !account!.enabled : true
    }
    
    private func connectionStateLabel(for account: AccountProfileModel) -> String? {
        if account.enabled {
            switch account.state {
            case .disconnected: return NSLocalizedString("disconnected", comment: "AccountPresenter disconnected")
            case .connecting: return NSLocalizedString("connecting", comment: "AccountPresenter connecting")
            case .connected: return NSLocalizedString("connected", comment: "AccountPresenter connected")
            case .disconnecting: return NSLocalizedString("disconnecting", comment: "AccountPresenter disconnecting")
            }
        } else {
            return NSLocalizedString("disabled", comment: "AccountPresenter disabled")
        }
    }
    
    private func nextConnectionLabel(for account: AccountProfileModel) -> String? {
        if let date = account.nextConnectionAttempt {
            let timeInterval = date.timeIntervalSinceNow
            if timeInterval > 0 {
                let template = NSLocalizedString("Reconnecting in %d seconds …", comment: "AccountPresenter reconnecting in x seconds")
                return String(format: template, Int(timeInterval))
            } else {
                return NSLocalizedString("Trying to reconnect …", comment: "AccountPresenter reconnecting")
            }
        } else {
            return nil
        }
    }
    
    private func errorMessageLabel(for account: AccountProfileModel) -> String? {
        if let error = account.error {
            return error.localizedDescription
        } else {
            return nil
        }
    }
    
    // Next Connection …
    
    private var displayLink: CADisplayLink?
    
    private func enableNextConnectionAttemptTimer() {
        let displayLink = CADisplayLink.init(target: self, selector: #selector(updateNextConnectionLabel))
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 2
        } else {
            displayLink.frameInterval = 30
        }
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.displayLink = displayLink
    }
    
    private func disableNextConnectionAttemptTimer() {
        if let displayLink = self.displayLink {
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    @objc private func updateNextConnectionLabel() {
        if let view = self.view {
            if let account = interactor?.account {
                view.nextAction = nextConnectionLabel(for: account)
            }
        }
    }
}
