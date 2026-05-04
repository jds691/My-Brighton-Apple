//
//  GradeColumn++.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/04/2026.
//

import LearnKit

nonisolated
extension GradeColumn {
    func isSubmitted(basedOn attempts: [GradebookAttempt]) -> Bool {
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
