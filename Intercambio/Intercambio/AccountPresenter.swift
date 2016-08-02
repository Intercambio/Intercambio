    //
//  AccountPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

class AccountPresenter : AccountOutput, AccountViewEventHandler {
    
    weak var view: AccountView? {
        didSet {
            updateView()
        }
    }
    
    var interactor: AccountProvider?
    var router: AccountRouter?
    
    private var displayLink: CADisplayLink?
    private var account: AccountPresentationModel?
    
    deinit {
        disableNextConnectionAttemptTimer()
    }
    
    func present(account: AccountPresentationModel) {
        self.account = account
        updateView()
        
        if account.nextConnectionAttempt != nil {
            enableNextConnectionAttemptTimer()
        } else {
            disableNextConnectionAttemptTimer()
        }
    }
    
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
           let uri = self.interactor?.account?.accountURI {
            router.presentSettingsUserInterface(for: uri)
        }
    }
    
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
    
    private func updateView() {
        if let view = self.view {
            if let account = self.account {
                view.accountLabel = account.identifier
                view.stateLabel = connectionStateLabel(for: account)
                view.nextConnectionLabel = nextConnectionLabel(for: account)
                view.errorMessageLabel = errorMessageLabel(for: account)
                view.connectionButtonEnabled = account.state == .disconnected
                view.connectionButtonHidden = account.state == .connected || !account.enabled
            }
        }
    }
    
    @objc private func updateNextConnectionLabel() {
        if let view = self.view {
            if let account = self.account {
                view.nextConnectionLabel = nextConnectionLabel(for: account)
            }
        }
    }
    
    private func connectionStateLabel(for account: AccountPresentationModel) -> String? {
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
    
    private func nextConnectionLabel(for account: AccountPresentationModel) -> String? {
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

    private func errorMessageLabel(for account: AccountPresentationModel) -> String? {
        if let error = account.error {
            return error.localizedDescription
        } else {
            return nil
        }
    }

}
