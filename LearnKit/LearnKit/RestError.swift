//
//  RestError.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

public struct RestError: Error {
    public private(set) var statusCode: Int?
    public private(set) var errorCode: String?
    public private(set) var message: String
    public private(set) var developerMessage: String?
    public private(set) var extraInfo: String?

    init(from restException: Components.Schemas.RestException) {
        if let status = restException.status {
            self.statusCode = Int(status)
        }
        self.errorCode = restException.code
        self.message = restException.message
        self.developerMessage = restException.developerMessage
        self.extraInfo = restException.extraInfo
    }
}

extension RestError: CustomDebugStringConvertible {
    public var debugDescription: String {
        developerMessage ?? message
    }
}

extension RestError: CustomStringConvertible {
    public var description: String {
        message
    }
}

/*
 public var status: Swift.String?
 /// The error code specific to a particular REST API. It is usually something that conveys information specific to the problem domain. For cases where the HTTP Status code conveys all the information required (such as a 404-Not Found) then the code may be omitted.
 ///
 /// - Remark: Generated from `#/components/schemas/RestException/code`.
 public var code: Swift.String?
 /// Error message that should be easy to understand and convey a concise reason as to why the error occurred.
 ///
 /// - Remark: Generated from `#/components/schemas/RestException/message`.
 public var message: Swift.String
 /// Represents any technical information that a developer calling REST API might find useful.
 ///
 /// - Remark: Generated from `#/components/schemas/RestException/developerMessage`.
 public var developerMessage: Swift.String?
 /// Indicates a URL that anyone seeing the error message can click in a browser. The target web page should describe the error condition fully, as well as potential solutions to help them resolve the error condition.
 ///
 /// - Remark: Generated from `#/components/schemas/RestException/extraInfo`.
 public var extraInfo: Swift.String?
 */
