//
//  MyStudiesView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import Router

// TODO: Navigating to this twice causes a rendering cycle on macOS
// https://github.com/users/jds691/projects/11/views/3?pane=issue&itemId=129420628

struct MyStudiesView: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(Router.self) private var router
    
    let columns = [
        // My personally preferred size, 3 cards when the sidebar is open
        GridItem(.adaptive(minimum: 300))
    ]
    
    @State private var searchTerm: String = ""
    
    var filteredModules: [Module] {
        Module.modules.filter({ searchTerm.isEmpty ? true : $0.name.lowercased().contains(searchTerm.lowercased()) })
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns) {
                Section {
                    ForEach(filteredModules, id: \.id) { module in
                        NavigationLink(value: Navigation.Route.MyStudiesSubRoute.module(module.id, nil)) {
                            MyStudiesModuleCard(name: module.name, image: module.image, displayId: module.displayId)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .contextMenu {
                            if supportsMultipleWindows {
                                Button {
                                    openWindow(id: "module", value: module.id)
                                } label: {
                                    Label("Open in New Window", systemImage: "macwindow.badge.plus")
                                }
                                
                                Divider()
                            }
                        }
                    }
                } header: {
                    Text("2024-25")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .scenePadding()
        }
        .myBrightonBackground()
        .navigationTitle("My Studies")
        .searchable(text: $searchTerm, prompt: "Search Modules")
        // TODO: Not being called on macOS
        // Idk wtf I'm supposed to do if macOS just won't call it
        // My only immediate guess is that iOS will call navigation destination when it's not on screen but macOS won't. However. Idfk
        // Potentially make one extremely large ViewModifier that contains each navigationDestination call
        .navigationDestination(for: Navigation.Route.MyStudiesSubRoute.self) { subroute in
            switch subroute {
                case .module(let moduleId, _):
                    ModuleView(id: moduleId)
            }
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview(traits: .environmentObjects) {
    @Previewable @State var router = Router.shared
    
    TabView {
        Tab {
            NavigationStack(path: $router.path) {
                MyStudiesView()
            }
        } label: {
            Label("My Studies", systemImage: "graduationcap")
        }
    }
    .environment(router)
}
