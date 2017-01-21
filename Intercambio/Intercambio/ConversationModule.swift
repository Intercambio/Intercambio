//
//  ConversationModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore
import XMPPMessageHub

public protocol ConversationModuleFactory {
    func makeContactPickerViewController() -> ContactPickerViewController?
}

public class ConversationModule : NSObject, ConversationModuleFactory {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public var contactPickerModule: ContactPickerModule?
    
    public func makeConversationViewController(for uri: URL?) -> ConversationViewController {
        let controller =  ConversationViewController(service: service, factory: self, conversation: uri)
        return controller
    }
    
    public func makeContactPickerViewController() -> ContactPickerViewController? {
        return contactPickerModule?.makeContactPickerViewController()
    }
}

extension ConversationViewController : ContactPickerViewControllerDelegate {
    public func contactPicker(_ picker: ContactPickerViewController, didSelect conversationURI: URL?) {
        if let presenter = self.presenter as? ConversationPresenter {
            presenter.conversation = conversationURI
        }
    }
}

public extension ConversationViewController {
    public convenience init(service: CommunicationService, factory: ConversationModuleFactory, conversation uri: URL?) {
        self.init()
        
        let presenter = ConversationPresenter(archiveManager: service.messageHub, accountManager: service.accountManager)
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
