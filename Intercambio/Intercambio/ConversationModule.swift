//
//  ConversationModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore
import XMPPMessageArchive

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
        let presenter = ConversationPresenter(db: service.messageDB)
        presenter.view = self
        presenter.conversation = uri
        self.presenter = presenter
        
        if uri == nil {
            if let contactPicker = factory.makeContactPickerViewController() {
                contactPickerViewController = contactPicker
                contactPicker.delegate = self
                isContactPickerVisible = true
            }
        }
    }
}

extension XMPPMessageDB : ConversationMessageDB {}
