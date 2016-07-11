    //
//  AccountModulePresenterImpl.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

public class AccountModulePresenterImpl : AccountModulePresenter {
    
    internal var userInterface: AccountModuleUserInterface?
    internal var displayLink: CADisplayLink?
    private var account: AccountViewModel?
    
    deinit {
        disableNextConnectionAttemptTimer()
    }
    
    public func present(account: AccountViewModel) {
        self.account = account
        updateInterface()
        
        if account.nextConnectionAttempt != nil {
            enableNextConnectionAttemptTimer()
        } else {
            disableNextConnectionAttemptTimer()
        }
    }
    
    private func enableNextConnectionAttemptTimer() {
        let displayLink = CADisplayLink.init(target: self, selector: #selector(updateNextConnectionLabel))
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 1
        } else {
            displayLink.preferredFrameRate = 1.0
        }
        displayLink.add(to: RunLoop.main(), forMode: RunLoopMode.defaultRunLoopMode.rawValue)
        self.displayLink = displayLink
    }
    
    private func disableNextConnectionAttemptTimer() {
        if let displayLink = self.displayLink {
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    private func updateInterface() {
        if var userInterface = self.userInterface {
            if let account = self.account {
                userInterface.accountLabel = account.identifier
                userInterface.stateLabel = connectionStateLabel(for: account)
                userInterface.nextConnectionLabel = nextConnectionLabel(for: account)
                userInterface.errorMessageLabel = errorMessageLabel(for: account)
                userInterface.connectionButtonEnabled = account.state == .disconnected
                userInterface.connectionButtonHidden = account.state == .connected || !account.enabled
                userInterface.nextConnectionLabelHidden = account.state != .disconnected || account.nextConnectionAttempt == nil
                userInterface.errorMessageLabelHidden = account.state == .connected || account.error == nil
            }
        }
    }
    
    @objc private func updateNextConnectionLabel() {
        if var userInterface = self.userInterface {
            if let account = self.account {
                userInterface.nextConnectionLabel = nextConnectionLabel(for: account)
            }
        }
    }
    
    private func connectionStateLabel(for account: AccountViewModel) -> String? {
        if account.enabled {
            switch account.state {
            case .disconnected: return NSLocalizedString("disconnected", comment: "AccountModulePresenterImpl disconnected")
            case .connecting: return NSLocalizedString("connecting", comment: "AccountModulePresenterImpl connecting")
            case .connected: return NSLocalizedString("connected", comment: "AccountModulePresenterImpl connected")
            case .disconnecting: return NSLocalizedString("disconnecting", comment: "AccountModulePresenterImpl disconnecting")
            }
        } else {
            return NSLocalizedString("disabled", comment: "AccountModulePresenterImpl disabled")
        }
    }
    
    private func nextConnectionLabel(for account: AccountViewModel) -> String? {
        if let date = account.nextConnectionAttempt {
            let timeInterval = date.timeIntervalSinceNow
            if timeInterval > 0 {
                let template = NSLocalizedString("Reconnecting in %d seconds …", comment: "AccountModulePresenterImpl reconnecting in x seconds")
                return String(format: template, Int(timeInterval))
            } else {
                return NSLocalizedString("Trying to reconnect …", comment: "AccountModulePresenterImpl reconnecting")
            }
        } else {
            return nil
        }
    }

    private func errorMessageLabel(for account: AccountViewModel) -> String? {
        if let error = account.error {
            return error.localizedDescription
        } else {
            return nil
        }
    }
}
