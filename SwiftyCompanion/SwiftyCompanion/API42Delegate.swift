//
//  API42Delegate.swift
//  SwiftyCompanion
//
//  Created by Lucas BELVALETTE on 11/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol API42Delegate{
    func handleResponse(user: JSON)
    func handleError(error: String)
}

