//
//  ConversationModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
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

import UIKit
import IntercambioCore
import XMPPMessageHub

public protocol ConversationModuleFactory {
    func makeContactPickerViewController() -> ContactPickerViewController?
}

public class ConversationModule: NSObject, ConversationModuleFactory {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public var contactPickerModule: ContactPickerModule?
    
    public func makeConversationViewController(for uri: URL?) -> ConversationViewController {
        let controller = ConversationViewController(service: service, factory: self, conversation: uri)
        return controller
    }
    
    public func makeContactPickerViewController() -> ContactPickerViewController? {
        return contactPickerModule?.makeContactPickerViewController()
    }
}

extension ConversationViewController: ContactPickerViewControllerDelegate {
    public func contactPicker(_: ContactPickerViewController, didSelect conversationURI: URL?) {
        if let presenter = self.presenter as? ConversationPresenter {
            presenter.conversation = conversationURI
        }
    }
}

public extension ConversationViewController {
    public convenience init(service: CommunicationService, factory: ConversationModuleFactory, conversation uri: URL?) {
        self.init()
        
        let presenter = ConversationPresenter(messageHub: service.messageHub, accountManager: service.accountManager)
        presenter.view = self
        self.presenter = presenter
        
        if let contactPicker = factory.makeContactPickerViewController() {
            contactPickerViewController = contactPicker
            contactPicker.delegate = self
        }
        
        conversationURI = uri
    }
    
    public var conversationURI: URL? {
        set {
            if let presenter = self.presenter as? ConversationPresenter {
                presenter.conversation = newValue
            }
            if let contactPicker = contactPickerViewController as? ContactPickerViewController {
                contactPicker.conversationURI = newValue
            }
        }
        get {
            if let presenter = self.presenter as? ConversationPresenter {
                return presenter.conversation
            } else {
                return nil
            }
        }
    }
}
