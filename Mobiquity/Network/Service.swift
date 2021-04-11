//
//  SerVices.swift
//  CooeyTest
//
//  Created by Saugata Chakraborty on 19/09/20.
//  Copyright © 2020 Saugata Chakraborty. All rights reserved.
//

import Alamofire

struct APIConstants {
    static let baseURL = "http://www.json-generator.com/"
    static let contentType = "application/json; charset=utf-8"
}

protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}

public class APIRouter: APIConfiguration {
    var method: HTTPMethod {
        return .post
    }
    var path: String {
        return ""
    }
    var parameters: Parameters?
    init(_ params: Parameters? = nil ) {
        parameters = params
    }
    public func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: URL.init(string: APIConstants.baseURL+path)!)
        request.setValue(APIConstants.contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        if method.rawValue == HTTPMethod.get.rawValue {
            return try URLEncoding.queryString.encode(request, with: parameters)
        } else {
            return try JSONEncoding.default.encode(request, with: parameters)
        }
    }
}

class CooeyAppService: NSObject {
    static func request(_ request: URLRequestConvertible, success:@escaping (Data) -> Void, failure:@escaping (CooeyAppError) -> Void) {
        AF.request(request).responseData { (responseObject) -> Void in
            if let data = responseObject.data {
                let decoder = JSONDecoder()
                if let item = try? decoder.decode(ProfileModel.self, from: data), item.count == 0 {
                    let error = CooeyAppServiceError.init(errorCode: CooeyAppServiceError.ErrorCode.unknownError)
                    failure(error)
                } else {
                    success(data)
                }
            } else {
                var item: CooeyAppError
                if let error = responseObject.error as NSError? {
                    item = CooeyAppServiceError.init(error: error)
                } else {
                    item = CooeyAppServiceError.init(errorCode: CooeyAppServiceError.ErrorCode.unknownError)
                }
                failure(item)
            }
        }
    }
}
