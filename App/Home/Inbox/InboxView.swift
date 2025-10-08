//
//  InboxView.swift
//  My Brighton
//
//  Created by Neo on 28/10/2023.
//

import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        root
            .navigationTitle("Inbox")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark")
                        }
                    }
                } else {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        #endif
    }
    
    @ViewBuilder
    private var root: some View {
        if false {
            List {
                
            }
        } else {
            ContentUnavailableView("No Notifications", systemImage: "bell")
        }
    }
}

#Preview {
    NavigationStack {
        InboxView()
    }
}
