//
//  AutomaticTopUpView.swift
//  My Brighton
//
//  Created by Neo on 05/09/2023.
//

import SwiftUI

struct AutomaticTopUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("""
Automatic Top-Up will add **£20** in credit to your UniCard when your balance falls **below £5**.

Your current payment method is **Apple Pay**. You can review and manage payment details in the Wallet app or online.
""")
                Button {
                    
                } label: {
                    Text("Adjust Threshhold or Top-Up Amount")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    
                } label: {
                    Text("Cancel Automatic Top-Up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .scenePadding()
            .navigationTitle("Automatic Top-Up")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    AutomaticTopUpView()
}
