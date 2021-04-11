//
//  Errors.swift
//  CooeyTest
//
//  Created by Saugata Chakraborty on 19/09/20.
//  Copyright © 2020 Saugata Chakraborty. All rights reserved.
//

import Foundation

public protocol CooeyAppErrorCode {
    var code: Int {get}
    var domain: String {get}
    var localizedMessage: String {get}
    var localizedTitle: String? {get}
}

open class CooeyAppError: NSError {
    public var errorCode: CooeyAppErrorCode
    open var localizedMessage: String {
        return errorCode.localizedMessage
    }
    open var localizedTitle: String? {
        return errorCode.localizedTitle
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    public init(errorCode: CooeyAppErrorCode) {
        self.errorCode = errorCode
        super.init(domain: errorCode.domain, code: errorCode.code, userInfo: nil)
    }
}

class CooeyAppServiceError: CooeyAppError {
    enum ErrorCode: Int, CooeyAppErrorCode {
        case unknownError
        case connectionError
        case requestTimeOut
        case noNetwork
        var code: Int {
            return rawValue
        }
        var domain: String {
            return "WebService"
        }
        var localizedMessage: String {
            switch self {
            case .unknownError:
                return "Unknown error. Please try again later."
            case .connectionError:
                return "Could not connect to server. Please try again later."
            case .noNetwork:
                return "Not connected to internet. Please check your connection"
            case .requestTimeOut:
                return "Request Timed out"
            }
        }
        var localizedTitle: String? {
            return "Cooey Assignment"
        }
    }
    static func customError(for error: NSError) -> ErrorCode {
        switch error.code {
        case -1009:
            return .noNetwork
        case -1001:
            return .requestTimeOut
        case -1008...(-1002):
            return .connectionError
        default:
            return .unknownError
        }
    }
    public convenience init(error: NSError) {
        let item = CooeyAppServiceError.customError(for: error)
        self.init(errorCode: item)
    }
}

class CooeyAppServerResponseError: CooeyAppError {
    static let JsonParsing = CooeyAppServerResponseError.init(errorCode: ErrorCode.jsonParsingError)
    static let Unknown = CooeyAppServerResponseError.init(errorCode: ErrorCode.unknownError)
    enum ErrorCode: CooeyAppErrorCode {
        case jsonParsingError
        case serverErrorMessage(String)
        case unknownError
        var code: Int {
            return 0
        }
        var domain: String {
            return "ServerResponse"
        }
        var localizedMessage: String {
            switch self {
            case .serverErrorMessage(let message):
                return message
            default:
                return "No Internet Connection Found!!!"
            }
        }
        var localizedTitle: String? {
            return "Cooey Assignment"
        }
    }
    public convenience init(error: String) {
        let item = ErrorCode.serverErrorMessage(error)
        self.init(errorCode: item)
    }
}

class CooeyAppErrorResponse: CooeyAppError {
    struct ErrorCode: CooeyAppErrorCode {
        let serverError: String
        var code: Int {
            return 100
        }
        var domain: String {
            return "APIResponse"
        }
        var localizedMessage: String {
            return "No Internet Connection Found!!!"
        }
        var localizedTitle: String? {
            return "Cooey Assignment"
        }
    }
    public convenience init(error: String) {
        let item = ErrorCode(serverError: error)
        self.init(errorCode: item)
    }
}
