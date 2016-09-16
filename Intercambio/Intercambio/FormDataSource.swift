//
//  FormDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain

public class FormSectionDataSource : FTMutableArray, FormSection {
    public var title: String?
    public var instructions: String?
}

public class FormDataSource : FTCombinedDataSource {
    public override func sectionItem(forSection section: UInt) -> Any! {
        if let dataSources = self.dataSources as NSArray? {
            return dataSources.object(at: Int(section))
        } else {
            return nil
        }
    }
}
