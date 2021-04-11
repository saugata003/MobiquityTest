//
//  ViewModel.swift
//  Mobiquity
//
//  Created by Saugata Chakraborty on 10/04/21.
//  Copyright © 2021 Azure. All rights reserved.
//

import Foundation
protocol ViewModelDelegate: class {
    func viewModelDidUpdate(sender: CooeyViewModel)
    func viewModelUpdateFailed(error: CooeyAppError)
}

class MobiquityViewModel: NSObject {
    weak var delegate: ViewModelDelegate?
}
