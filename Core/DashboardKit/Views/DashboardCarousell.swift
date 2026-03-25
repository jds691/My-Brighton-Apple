//
//  DashboardCarousell.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

import SwiftUI
import CoreDesign

public struct DashboardCarousell: View {
    public init(for dashboardId: Dashboard.ID) {
        
    }

    public var body: some View {
        if false {
            ScrollView(.horizontal) {

            }
        } else {
            NoContentView("No Recent Updates")
                .frame(height: 80)
        }
    }
}
