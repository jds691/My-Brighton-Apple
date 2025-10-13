//
//  BbCacheTests.swift
//  My Brighton
//
//  Created by Neo Salmon on 13/10/2025.
//

import Testing
import Foundation
@testable import LearnKit

extension Tag {
    @Tag static var swiftData: Self
}

struct BbCacheTests {
    @Suite(.tags(.swiftData))
    struct Courses {
        // Each test will receive it's own instance of this so theres no possibility of breaking stuff :P
        let cache = BbCache(inMemoryOnly: true)

        @Test
        func allCoursesIndexed() async throws {
            let sampleTerm = Term(
                id: "_term_0",
                externalId: nil,
                dataSourceId: nil,
                name: "Sample Term",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            let course = Course(
                id: "0",
                uuid: nil,
                externalId: nil,
                dataSourceId: nil,
                courseId: "",
                name: "",
                description: "",
                creationDate: nil,
                lastModified: .now,
                isOrganisation: false,
                ultraStatus: .ultra,
                allowGuests: nil,
                allowObservers: nil,
                isComplete: false,
                termId: sampleTerm.id,
                availability: Course.Availability(status: Course.Availability.Status.yes, duration: Course.Availability.Duration.continuous),
                enrollmentType: Course.Enrollment.emailEnrollment,
                localeSettings: Course.LocaleSettings(identifier: nil, forceLocale: false),
                hasChildren: nil,
                parentId: nil,
                externalAccessUrl: URL(string: "https://example.com")!,
                guestAccessUrl: nil
            )

            let newCourse = Course(
                id: "1",
                uuid: nil,
                externalId: nil,
                dataSourceId: nil,
                courseId: "",
                name: "New Name",
                description: "",
                creationDate: nil,
                lastModified: .now,
                isOrganisation: false,
                ultraStatus: .ultra,
                allowGuests: nil,
                allowObservers: nil,
                isComplete: false,
                termId: sampleTerm.id,
                availability: Course.Availability(status: Course.Availability.Status.yes, duration: Course.Availability.Duration.continuous),
                enrollmentType: Course.Enrollment.emailEnrollment,
                localeSettings: Course.LocaleSettings(identifier: nil, forceLocale: false),
                hasChildren: nil,
                parentId: nil,
                externalAccessUrl: URL(string: "https://example.com")!,
                guestAccessUrl: nil
            )

            let newCourse2 = Course(
                id: "2",
                uuid: nil,
                externalId: nil,
                dataSourceId: nil,
                courseId: "",
                name: "New Name",
                description: "",
                creationDate: nil,
                lastModified: .now,
                isOrganisation: false,
                ultraStatus: .ultra,
                allowGuests: nil,
                allowObservers: nil,
                isComplete: false,
                termId: sampleTerm.id,
                availability: Course.Availability(status: Course.Availability.Status.yes, duration: Course.Availability.Duration.continuous),
                enrollmentType: Course.Enrollment.emailEnrollment,
                localeSettings: Course.LocaleSettings(identifier: nil, forceLocale: false),
                hasChildren: nil,
                parentId: nil,
                externalAccessUrl: URL(string: "https://example.com")!,
                guestAccessUrl: nil
            )

            await cache.indexTerms([sampleTerm])
            await cache.indexCourses([course, newCourse, newCourse2])

            let courses = try await cache.getAllCourses()

            #expect(courses.count == 3)

            let courseIds: [String] = courses.compactMap({ $0.id })
            #expect(courseIds.sorted() == ["0", "1", "2"])
        }

        @Test
        func nilForNonexistentCourse() async throws {
            let course: Course? = try await cache.getCourse(for: "idk")
            #expect(course == nil)
        }

        @Test
        func courseUpdatedNotDuplicated() async throws {
            let sampleTerm = Term(
                id: "_term_0",
                externalId: nil,
                dataSourceId: nil,
                name: "Sample Term",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            let course = Course(
                id: "0",
                uuid: nil,
                externalId: nil,
                dataSourceId: nil,
                courseId: "",
                name: "",
                description: "",
                creationDate: nil,
                lastModified: .now,
                isOrganisation: false,
                ultraStatus: .ultra,
                allowGuests: nil,
                allowObservers: nil,
                isComplete: false,
                termId: sampleTerm.id,
                availability: Course.Availability(status: Course.Availability.Status.yes, duration: Course.Availability.Duration.continuous),
                enrollmentType: Course.Enrollment.emailEnrollment,
                localeSettings: Course.LocaleSettings(identifier: nil, forceLocale: false),
                hasChildren: nil,
                parentId: nil,
                externalAccessUrl: URL(string: "https://example.com")!,
                guestAccessUrl: nil
            )

            let newCourse = Course(
                id: "0",
                uuid: nil,
                externalId: nil,
                dataSourceId: nil,
                courseId: "",
                name: "New Name",
                description: "",
                creationDate: nil,
                lastModified: .now,
                isOrganisation: false,
                ultraStatus: .ultra,
                allowGuests: nil,
                allowObservers: nil,
                isComplete: false,
                termId: sampleTerm.id,
                availability: Course.Availability(status: Course.Availability.Status.yes, duration: Course.Availability.Duration.continuous),
                enrollmentType: Course.Enrollment.emailEnrollment,
                localeSettings: Course.LocaleSettings(identifier: nil, forceLocale: false),
                hasChildren: nil,
                parentId: nil,
                externalAccessUrl: URL(string: "https://example.com")!,
                guestAccessUrl: nil
            )

            await cache.indexTerms([sampleTerm])

            await cache.indexCourses([course])

            let fetchedCourse: Course? = try await cache.getCourse(for: course.id)
            try #require(fetchedCourse != nil)

            #expect(fetchedCourse!.name == "")

            await cache.indexCourses([newCourse])

            let newFetchedCourse: Course? = try await cache.getCourse(for: course.id)
            try #require(newFetchedCourse != nil)
            #expect(newFetchedCourse!.name == "New Name")
        }
    }

    @Suite(.tags(.swiftData))
    struct Terms {
        let cache = BbCache(inMemoryOnly: true)

        @Test
        func allTermsIndexed() async throws {
            let term = Term(
                id: "0",
                externalId: nil,
                dataSourceId: nil,
                name: "",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            let term1 = Term(
                id: "1",
                externalId: nil,
                dataSourceId: nil,
                name: "",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            let term2 = Term(
                id: "2",
                externalId: nil,
                dataSourceId: nil,
                name: "",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            await cache.indexTerms([term, term1, term2])

            let terms = try await cache.getAllTerms()

            #expect(terms.count == 3)

            let termIds: [String] = terms.compactMap({ $0.id })
            #expect(termIds.sorted() == ["0", "1", "2"])
        }

        @Test
        func nilForNonexistentTerm() async throws {
            let term: Term? = try await cache.getTerm(for: "idk")
            #expect(term == nil)
        }

        @Test
        func termUpdatedNotDuplicated() async throws {
            let sampleTerm = Term(
                id: "0",
                externalId: nil,
                dataSourceId: nil,
                name: "",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            let newSampleTerm = Term(
                id: "0",
                externalId: nil,
                dataSourceId: nil,
                name: "Sample",
                description: nil,
                availability: .init(isAvailable: true, duration: .continuous)
            )

            await cache.indexTerms([sampleTerm])

            let fetchedTerm: Term? = try await cache.getTerm(for: sampleTerm.id)
            try #require(fetchedTerm != nil)

            #expect(fetchedTerm!.name == "")

            await cache.indexTerms([newSampleTerm])

            let newFetchedTerm: Term? = try await cache.getTerm(for: newSampleTerm.id)
            try #require(newFetchedTerm != nil)

            #expect(newFetchedTerm!.name == "Sample")
        }
    }
}
