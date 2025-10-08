//
//  LearnKit+Previews.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import SwiftUI
import LearnKit

public extension EnvironmentValues {
     @Entry var learnKitService: LearnKitService = LearnKitService(learnInstanceURL: .init(string: "https://example.com")!)
}

struct LearnKitPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> LearnKitService {
        //return LearnKitService(client: PreviewClient())
        return LearnKitService(learnInstanceURL: .init(string: "https://example.com")!)
    }

    func body(content: Self.Content, context: LearnKitService) -> some View {
        content
            .environment(\.learnKitService, context)
    }
}

extension PreviewTrait {
    static var learnKit: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(LearnKitPreviewModifier())
        )
    }
}

/*fileprivate struct PreviewClient: APIProtocol {



    // MARK: Authentication
    func getV1Oauth2Authorizationcode(_ input: LearnKit.Operations.GetV1Oauth2Authorizationcode.Input) async throws -> LearnKit.Operations.GetV1Oauth2Authorizationcode.Output {
        fatalError()
    }

    func postV1Oauth2Token(_ input: LearnKit.Operations.PostV1Oauth2Token.Input) async throws -> LearnKit.Operations.PostV1Oauth2Token.Output {
        fatalError()
    }

    func getV1Oauth2Tokeninfo(_ input: LearnKit.Operations.GetV1Oauth2Tokeninfo.Input) async throws -> LearnKit.Operations.GetV1Oauth2Tokeninfo.Output {
        fatalError()
    }

    // MARK: Adaptive Release
    func getV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Output {
        fatalError()
    }

    func postV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules(_ input: LearnKit.Operations.PostV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Input) async throws -> LearnKit.Operations.PostV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Output {
        fatalError()
    }

    func getV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Output {

    }
}
*/
