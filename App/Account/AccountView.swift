//
//  AccountView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import PassKit
import Router
import CoreDesign

@available(*, deprecated)
struct AccountView: View {
    let manageOnlineURL = URL(string: "https://unicardcentral.brighton.ac.uk")!
    
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(Router.self) private var router: Router
    
    @State private var showAutoTopUp: Bool = false
    @State private var showManageOnline: Bool = false
    
    @State private var showSignOut: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    StudentIDCard()
                        .frame(maxWidth: 400)
                    
                    #if os(iOS) && APPLE_ACCESS
                    if PKAddPassesViewController.canAddPasses() {
                        /*AddPassToWalletButton {
                            
                        }
                        .addPassToWalletButtonStyle(colorScheme == .light ? .black : .blackOutline)*/
                        
                        ProgressView("Generating UniCard for Apple Wallet...")
                        /*Button("View in Apple Wallet") {
                            
                        }
                        .frame(maxWidth: .infinity)*/
                    }
                    #endif
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(.init(
                    top: 0,
                    leading: 0,
                    bottom: 5,
                    trailing: 0))
                .listRowBackground(EmptyView())
                .listSectionSeparator(.hidden)
                
                Section {
                    Button {
                        showAutoTopUp = true
                    } label: {
                        HStack {
                            Label("Automatic Top-Up", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            Text("Inactive")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .sheet(isPresented: $showAutoTopUp) {
                        AutomaticTopUpView()
                        .presentationDetents([
                            .medium
                        ])
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Top-Up", systemImage: "sterlingsign")
                    }
                    
                    Button {
                        #if os(iOS)
                        if #available(iOS 26, *) {
                            openURL(manageOnlineURL, prefersInApp: true)
                        } else {
                            showManageOnline = true
                        }
                        #else
                        openURL(manageOnlineURL)
                        #endif
                    } label: {
                        Label("Manage More Online", systemImage: "globe")
                    }
                } header: {
                    Text("UniCard")
                        .accessibilityLabel(Text("Uni Card"))
                }
                
                Section("Settings") {
                    NavigationLink(value: 1) {
                        Label("General", systemImage: "gear")
                    }
                    NavigationLink(value: 2) {
                        Label("Notifications", systemImage: "bell.badge")
                    }
                }
                
                Section {
                    Button {
                        
                    } label: {
                        Label("Send Feedback", systemImage: "text.bubble")
                    }
                }
            }
            .navigationTitle("Account")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                    .labelStyle(.designSystemAware)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .destructive) {
                        showSignOut = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward")
                    }
                    .labelStyle(.designSystemAware)
                }
            }
            .alert("Sign Out", isPresented: $showSignOut) {
                Button(role: .destructive) {
                    
                } label: {
                    Text("Sign Out")
                }
            } message: {
                Text("")
            }
            #if os(iOS)
            .sheet(isPresented: $showManageOnline) {
                SafariView(url: manageOnlineURL)
                    .ignoresSafeArea()
            }
            #endif
        }
    }
}
