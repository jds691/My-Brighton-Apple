//
//  StudentIDCard.swift
//  My Brighton
//
//  Created by Neo on 26/08/2023.
//

import Foundation
import SwiftUI
import CustomisationKit

@available(*, deprecated)
struct StudentIDCard: View {
    private let homeCustomisation: HomeCustomisation

    init() {
        homeCustomisation = CustomisationService.shared.getHomeCustomisation()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("University of Brighton")
                .font(.headline)
                .scenePadding([.horizontal, .top])
                .foregroundStyle(contentColor)
            
            Image("placeholder/StudentIdBanner", bundle: Bundle(for: CustomisationService.self))
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 100, alignment: .center)
                .offset(y: -30)
                .clipped()
                /*.overlay(
                    Rectangle()
                        .inset(by: 0.5)
                        .stroke(.white, lineWidth: 1)
                )*/
                .overlay(alignment: .leading) {
                    studentDetails
                        .scenePadding()
                }
                .drawingGroup()
                
            Spacer()
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Student Number")
                        .font(.headline)
                        .foregroundStyle(labelColor)
                        .accessibilityValue(Text(Bundle.main.studentNumber))
                    Text(Bundle.main.studentNumber)
                        .foregroundStyle(contentColor)
                        .accessibilityHidden(true)
                        .textSelection(.enabled)
                        //.redacted(reason: .placeholder)
                }
                
                /*VStack(alignment: .leading, spacing: 0) {
                    Text("Balance")
                        .font(.headline)
                        .foregroundStyle(labelColor)
                        .accessibilityValue(Text("£30.00"))
                    Text("£30.00")
                        .foregroundStyle(contentColor)
                        .accessibilityHidden(true)
                        .redacted(reason: .placeholder)
                }*/
                
                /*VStack(alignment: .leading, spacing: 0) {
                    Text("Print Funds")
                        .font(.headline)
                        .foregroundStyle(labelColor)
                        .accessibilityValue(Text("£30.00"))
                    Text("£30.00")
                        .foregroundStyle(contentColor)
                        .accessibilityHidden(true)
                }*/
                
                /*VStack(alignment: .leading, spacing: 0) {
                    Text("MyCup Stamps")
                        .font(.headline)
                        .foregroundStyle(labelColor)
                        .accessibilityValue(Text("9"))
                    Text("9")
                        .foregroundStyle(contentColor)
                        .accessibilityHidden(true)
                        .redacted(reason: .placeholder)
                }*/
            }
            .scenePadding(.horizontal)
            Spacer()
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 225.73, alignment: .topLeading)
        .background(backgroundColor)
        .cornerRadius(16)
        .aspectRatio(aspectRatio, contentMode: .fit)
        .shadow(radius: 2, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var studentDetails: some View {
        VStack(alignment: .leading) {
            // TODO: Source hard coded name elsewhere
            Text(homeCustomisation.displayNameOverride ?? "Neo")
                .font(.title3.bold())
            Text("Student")
        }
    }
    
    private var aspectRatio: CGFloat {
        358 / 225.73
    }
    
    private var backgroundColor: Color {
        .white
    }
    
    private var labelColor: Color {
        .studentBlue
    }
    
    private var contentColor: Color {
        .black
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    StudentIDCard()
}
