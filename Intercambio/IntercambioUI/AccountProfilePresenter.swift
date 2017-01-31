//
//  AccountProfilePresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
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
