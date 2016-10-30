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

    public func viewController() -> UIViewController? {
        let view = ContactPickerViewController()
        return view
    }
}
