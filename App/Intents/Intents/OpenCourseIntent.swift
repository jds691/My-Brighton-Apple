//
//  OpenCourseIntent.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//

import LearnKit
import AppIntents
import Router

struct OpenCourseIntent: AppIntent, OpenIntent {
    static let title: LocalizedStringResource = "Open Course"
    static let description: IntentDescription? = IntentDescription("Opens the provided course")

    @Parameter(title: "Course", description: "Course to open")
    var target: CourseEntity
    
    @Dependency
    private var router: Router

    public init() {
        
    }

    public init(course: CourseEntity) {
        self.target = course
    }

    func perform() async throws -> some IntentResult {
        await router.navigate(to: .route(.myStudies(.module(target.id, nil))))
        return .result()
    }
}

extension OpenCourseIntent: PredictableIntent {
    public static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: \.$target, displayRepresentation: { course in
                .init(stringLiteral: "Open \(course.name)")
        })
    }
}
