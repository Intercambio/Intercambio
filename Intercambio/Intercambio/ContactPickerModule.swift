//
//  ContactPickerModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 30.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class ContactPickerModule : NSObject {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }

    public func makeContactPickerViewController() -> ContactPickerViewController {
        let controller = ContactPickerViewController(service: service)
        return controller
    }
}

public protocol ContactPickerViewControllerDelegate : class {
    func contactPicker(_ picker: ContactPickerViewController, didSelect conversationURI: URL?)
}

public extension ContactPickerViewController {
    
    private class DelegateProxy : ContactPickerPresenterEventHandler {
        weak var delegate: ContactPickerViewControllerDelegate?
        weak var viewController: ContactPickerViewController?
        
        func didChange(conversation uri: URL?) {
            if let delegate = self.delegate,
                let viewController = self.viewController {
                delegate.contactPicker(viewController, didSelect: uri)
            }
        }
    }
    
    public convenience init(service: CommunicationService) {
        self.init()
        let presenter = ContactPickerPresenter(accountManager: service.accountManager)
        presenter.view = self
        
        let proxy = DelegateProxy()
        proxy.viewController = self
        presenter.eventHandler = proxy
        
        self.presenter = presenter
    }
    
    public var conversationURI: URL? {
        set {
            if let presenter = self.presenter as? ContactPickerPresenter {
                return presenter.conversationURI = newValue
            }
        }
        get {
            if let presenter = self.presenter as? ContactPickerPresenter {
                return presenter.conversationURI
            } else {
                return nil
            }
        }
    }
    
    public weak var delegate: ContactPickerViewControllerDelegate? {
        set {
            if let proxy = delegateProxy {
                proxy.delegate = newValue
            }
        }
        get {
            if let proxy = delegateProxy {
                return proxy.delegate
            } else {
                return nil
            }
        }
    }
    
    private var delegateProxy: DelegateProxy? {
        if let presenter = self.presenter as? ContactPickerPresenter,
           let proxy = presenter.eventHandler as? DelegateProxy{
            return proxy
        }
        return nil
    }
}
