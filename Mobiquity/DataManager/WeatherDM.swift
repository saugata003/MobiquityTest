//
//  UserProfileDM.swift
//  Mobiquity
//
//  Created by Saugata Chakraborty on 10/04/21.
//  Copyright © 2021 Azure. All rights reserved.
//

import Alamofire
enum WeatherRoute: String {
//    APIConstants.appId
    case weatherUrl = "weather"
}

public class WeatherRouter: APIRouter {
    let route: WeatherRoute
    override var method: HTTPMethod {
        return .get
    }
    init(_ params: [String: Any]? = nil, route: WeatherRoute) {
        self.route = route
        super.init(params)
    }
    override var path: String {
        return route.rawValue
    }
}

class UserProfileDM: NSObject {
    public func getProfileList(success: @escaping (Data) -> Void, failure: @escaping(CooeyAppError) -> Void) {
        let router = WeatherRoute(nil, route: .weatherUrl)
        CooeyAppService.request(router, success: success, failure: failure)
    }
}
