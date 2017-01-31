//
//  ContactPickerModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 30.10.16.
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
