//
//  GradeColumn++.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/04/2026.
//

import LearnKit

extension GradeColumn {
    func isSubmitted(in courseIdentifier: Course.ID, using learnKit: LearnKitService) async -> Bool {
        guard let cachedAttempts = try? await learnKit.getGradebookAttempts(for: self.id, in: courseIdentifier) else { return false }

        let attempts: [GradebookAttempt]
        if cachedAttempts.isEmpty {
            guard let refreshedAttempts = try? await learnKit.refreshGradebookAttempts(for: self.id, in: courseIdentifier) else { return false }

            attempts = refreshedAttempts
        } else {
            attempts = cachedAttempts
        }

        switch self.grading.scoringModel {
            case .last:
                return attempts
                        .sorted(by: { $0.created > $1.created })
                        .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil

            case .highest:
                return attempts
                        .sorted(by: { ($0.score ?? -1) > ($1.score ?? -1) })
                        .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil

            case .lowest:
                return attempts
                        .sorted(by: { ($0.score ?? -1) < ($1.score ?? -1) })
                        .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil

            case .first:
                return attempts
                        .sorted(by: { $0.created < $1.created })
                        .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil

            case .average:
                return false
        }
    }
}
