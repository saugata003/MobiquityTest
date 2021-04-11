//
//  Encodable+Additions.swift
//  IMM-iOS
//
//  Created by Saugata Chakraborty on 28/05/19.
//  Copyright © 2019 OIT. All rights reserved.
//

import Foundation
extension Encodable {
    var dictionary: [String: AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyObject] }
    }
    var array: [AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [AnyObject] }
    }
}
