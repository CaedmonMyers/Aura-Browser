//
//  TabOverview.swift
//  Aura
//
//  Created by Caedmon Myers on 25/6/24.
//

import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI
import SwiftData

struct TabOverview: View {
    @Namespace var namespace
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    @Binding var selectedSpaceIndex: Int
    @Environment(\.modelContext) private var modelContext
    
    @State private var tabs: [(id: UUID, url: String)]
    @State private var pinnedTabs: [(id: UUID, url: String)]
    @State private var favoriteTabs: [(id: UUID, url: String)]
    @State private var offsets: [UUID: CGSize] = [:]
    @State private var tilts: [UUID: Double] = [:]
    @State private var zIndexes: [UUID: Double] = [:]
    
    @State var selectedTab: (id: UUID, url: String)?
    
    @EnvironmentObject var variables: ObservableVariables
    @StateObject var settings = SettingsVariables()
    
    //@StateObject private var webViewModel = WebViewModel()
    
    @State var selectedTabsSection: TabLocations = .tabs
    
    @FocusState var newTabFocus: Bool
    @State var newTabSearch = ""
    
    @State var fullScreenWebView = false
    
    @State var suggestions = [] as [String]
    @State var xmlString = ""
    
    @State var offsetTest = 0 as CGFloat
    
    @State var tabOffset = CGSize.zero
    @State var tabScale: CGFloat = 1.0
    
    @State var exponentialThing = 1.0
    
    @State var gestureStarted = false
    
    init(selectedSpaceIndex: Binding<Int>) {
        self._selectedSpaceIndex = selectedSpaceIndex
        self._tabs = State(initialValue: [])
        self._pinnedTabs = State(initialValue: [])
        self._favoriteTabs = State(initialValue: [])
    }
    
    var body: some View {
        GeometryReader { geo in
                    ZStack {
                        if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                            LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                .animation(.linear)
                        }
                        else {
                            LinearGradient(colors: [variables.startColor, variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                .animation(.linear)
                        }
                        
                        ScrollView {
                            VStack {
                                LazyVGrid(columns: [GridItem(spacing: 5), GridItem(spacing: 5)], content: {
                                    ForEach(selectedTabsSection == .tabs ? tabs: selectedTabsSection == .pinned ? pinnedTabs: favoriteTabs, id: \.id) { tab in
                                        let offset = offsets[tab.id, default: .zero]
                                        WebPreview(namespace: namespace, url: tab.url, geo: geo, tab: tab)
                                            .rotationEffect(Angle(degrees: tilts[tab.id, default: 0.0]))
                                            .offset(x: offset.width)
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.white.opacity(0.0001))
                                                    .onTapGesture {
                                                        if newTabFocus {
                                                            newTabFocus = false
                                                        }
                                                        else {
                                                            withAnimation {
                                                                selectedTab = tab
                                                                fullScreenWebView = true
                                                            }
                                                        }
                                                    }
                                            })
                                            .simultaneousGesture(
                                                DragGesture(minimumDistance: 20)
                                                    .onChanged { gesture in
                                                        if newTabFocus {
                                                            newTabFocus = false
                                                        }
                                                        else {
                                                            handleDragChange(gesture, for: tab.id)
                                                        }
                                                    }
                                                    .onEnded { gesture in
                                                        if newTabFocus {
                                                            newTabFocus = false
                                                        }
                                                        else {
                                                            handleDragEnd(gesture, for: tab.id)
                                                        }
                                                    }
                                            )
                                    }
                                })
                                .padding(10)
                                
                                Spacer()
                                    .frame(height: 120)
                            }
                        }.onTapGesture(perform: {
                            if newTabFocus {
                                newTabFocus = false
                            }
                        })
                        
                        HStack {
                            Spacer()
                            
                            VStack {
                                Button(action: {
                                    withAnimation {
                                        selectedTabsSection = .favorites
                                    }
                                }, label: {
                                    Image(systemName: "star")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: selectedTabsSection == .favorites ? 30: 20, height: selectedTabsSection == .favorites ? 30: 20)
                                        .opacity(selectedTabsSection == .favorites ? 1.0: 0.4)
                                        .foregroundStyle(Color(hex: "4D4D4D"))
                                })
                                .highPriorityGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let dragHeight = value.translation.height
                                            if dragHeight > 120 {
                                                selectedTabsSection = .tabs
                                            } else if dragHeight > 60 {
                                                selectedTabsSection = .pinned
                                            }
                                            else {
                                                selectedTabsSection = .favorites
                                            }
                                        }
                                )
                                .frame(height: 30)
                                .padding(.vertical, 5)
                                
                                Button(action: {
                                    withAnimation {
                                        selectedTabsSection = .pinned
                                    }
                                }, label: {
                                    Image(systemName: "pin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: selectedTabsSection == .pinned ? 30: 20, height: selectedTabsSection == .pinned ? 30: 20)
                                        .opacity(selectedTabsSection == .pinned ? 1.0: 0.4)
                                        .foregroundStyle(Color(hex: "4D4D4D"))
                                })
                                .highPriorityGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let dragHeight = value.translation.height
                                            if dragHeight > 60 {
                                                selectedTabsSection = .tabs
                                            } else if dragHeight < -60 {
                                                selectedTabsSection = .favorites
                                            }
                                            else {
                                                selectedTabsSection = .pinned
                                            }
                                        }
                                )
                                .frame(height: 30)
                                .padding(.vertical, 5)
                                
                                Button(action: {
                                    withAnimation {
                                        selectedTabsSection = .tabs
                                    }
                                }, label: {
                                    Image(systemName: "calendar.day.timeline.left")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: selectedTabsSection == .tabs ? 30: 20, height: selectedTabsSection == .tabs ? 30: 20)
                                        .opacity(selectedTabsSection == .tabs ? 1.0: 0.4)
                                        .foregroundStyle(Color(hex: "4D4D4D"))
                                })
                                .highPriorityGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let dragHeight = value.translation.height
                                            if dragHeight < -120 {
                                                selectedTabsSection = .favorites
                                            } else if dragHeight < -60 {
                                                selectedTabsSection = .pinned
                                            }
                                            else {
                                                selectedTabsSection = .tabs
                                            }
                                        }
                                )
                                .frame(height: 30)
                                .padding(.vertical, 5)
                            }
                            .frame(width: 50, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(.regularMaterial)
                            )
                            .padding(.trailing, 5)
                        }.padding(2)
                        
                        if fullScreenWebView {
                            WebsiteView(namespace: namespace, url: selectedTab!.url, parentGeo: geo, fullScreenWebView: $fullScreenWebView, tab: selectedTab!)
                                .offset(x: tabOffset.width, y: tabOffset.height)
                                .scaleEffect(tabScale)
                        }
                        
                        VStack {
                            Spacer()
                                .offset(x: tabOffset.width, y: tabOffset.height)
                                .scaleEffect(tabScale)
                            
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    if newTabFocus {
                                        ForEach(Array(suggestions.prefix(5)), id:\.self) { suggestion in
                                            Button(action: {
                                                withAnimation {
                                                    newTabFocus = false
                                                    createTab(url: formatURL(from: suggestion))
                                                    newTabSearch = ""
                                                    //fullScreenWebView = true
                                                }
                                            }, label: {
                                                ZStack {
                                                    ZStack {
                                                        Capsule()
                                                            .fill(
                                                                .white.gradient.shadow(.inner(color: .black.opacity(0.2), radius: 10, x: 0, y: -3))
                                                            )
                                                            .animation(.default, value: newTabFocus)
                                                    }
                                                    
                                                    HStack {
                                                        Text(suggestion)
                                                            .animation(.default)
                                                            .foregroundColor(Color(hex: "4D4D4D"))
                                                            .font(.system(.headline, design: .rounded, weight: .bold))
                                                            .padding(.horizontal, 10)
                                                        
                                                        Spacer()
                                                    }
                                                    
                                                }.frame(height: 50)
                                                    .padding(.horizontal, 10)
                                            })
                                        }
                                    }
                                }.rotationEffect(Angle(degrees: 180))
                                .onChange(of: newTabSearch, perform: { value in
                                    Task {
                                        await fetchXML(searchRequest: newTabSearch)
                                    }
                                    
                                    Task {
                                        await suggestions = formatXML(from: xmlString)
                                    }
                                })
                                .onChange(of: newTabFocus, perform: { newValue in
                                    if !newTabFocus {
                                        suggestions.removeAll()
                                    }
                                })
                            }.rotationEffect(Angle(degrees: 180))
                            
                            ZStack {
                                Rectangle()
                                    .fill(.thinMaterial)
                                    .frame(height: newTabFocus ? 75: 150)
                                
                                VStack {
                                    
                                    if !fullScreenWebView {
                                        HStack {
                                            ZStack {
                                                ZStack {
                                                    Capsule()
                                                        .fill(.white)
                                                        .animation(.default, value: newTabFocus)
                                                }
                                                
                                                TextField("Search or enter url", text: $newTabSearch)
                                                    .focused($newTabFocus)
                                                    .opacity(newTabFocus ? 1.0: 0.0)
                                                    .keyboardType(.webSearch)
                                                    .textInputAutocapitalization(.never)
                                                    .autocorrectionDisabled(true)
                                                    .submitLabel(.search)
                                                    .scrollDismissesKeyboard(.interactively)
                                                    .tint(Color(.systemBlue))
                                                    .animation(.default, value: newTabFocus)
                                                    .foregroundColor(Color(hex: "4D4D4D"))
                                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                                    .padding(.horizontal, newTabFocus ? 10: 0)
                                                    .onSubmit({
                                                        withAnimation {
                                                            newTabFocus = false
                                                            createTab(url: formatURL(from: newTabSearch))
                                                            newTabSearch = ""
                                                            //fullScreenWebView = true
                                                        }
                                                    })
                                                
                                            }.frame(width: newTabFocus ? .infinity: 0, height: 50)
                                            
                                            
                                            Button(action: {
                                                if !newTabFocus {
                                                    withAnimation {
                                                        newTabFocus = true
                                                    }
                                                } else {
                                                    withAnimation {
                                                        newTabFocus = false
                                                        createTab(url: formatURL(from: newTabSearch))
                                                        newTabSearch = ""
                                                        //fullScreenWebView = true
                                                    }
                                                }
                                            }, label: {
                                                Image(systemName: newTabFocus ? "magnifyingglass": "plus")
                                            }).buttonStyle(PlusButtonStyle())
                                            
                                        }.padding(.leading, newTabFocus ? 10: 0)
                                        
                                        
                                        if !newTabFocus {
                                            spaceSelector
                                        }
                                    }
                                    else {
                                        VStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.white)
                                                    .frame(height: 50)
                                                    .padding(.horizontal, 15)
                                                    .offset(x: tabOffset.width, y: tabOffset.height)
                                                    .scaleEffect(tabScale)
                                                    .gesture(
                                                        DragGesture()
                                                            .onChanged { gesture in
                                                                withAnimation {
                                                                    gestureStarted = true
                                                                }
                                                                exponentialThing = exponentialThing * 0.99
                                                                var dragX = min(max(gesture.translation.width, -50), 50)
                                                                dragX *= exponentialThing
                                                                
                                                                let dragY = gesture.translation.height
                                                                if dragY < 0 { // Only allow upward movement
                                                                    let slowDragY = dragY * 0.3 // Drag up slower
                                                                    tabOffset = CGSize(width: dragX, height: slowDragY)
                                                                    tabScale = 1 - min(-slowDragY / 200, 0.5)
                                                                }
                                                            }
                                                            .onEnded { gesture in
                                                                exponentialThing = 1
                                                                withAnimation {
                                                                    gestureStarted = false
                                                                }
                                                                if gesture.translation.height < -100 {
                                                                    //self.presentationMode.wrappedValue.dismiss()
                                                                    withAnimation {
                                                                        fullScreenWebView = false
                                                                    }
                                                                }
                                                                    withAnimation(.spring()) {
                                                                        tabOffset = .zero
                                                                        tabScale = 1.0
                                                                    }
                                                                
                                                            }
                                                    )
                                                
                                                //Text(webViewModel.currentURL?.absoluteString ?? "")
                                            }
                                        }
                                    }
                                }
                            }
                        }.ignoresSafeArea(.container, edges: .all)
                        
                        /*if fullScreenWebView {
                            WebsiteView(namespace: namespace, url: selectedTab!.url, parentGeo: geo, fullScreenWebView: $fullScreenWebView, tab: selectedTab!)
                        }*/
                        
                    }
            
            
        }
        .onAppear {
            updateTabs()
        }
    }
    
    private var spaceSelector: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack(spacing: 10) {
                        ForEach(spaces.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    withAnimation {
                                        selectedSpaceIndex = index
                                        updateTabs()
                                        proxy.scrollTo(index, anchor: .center) // Snap to center on tap
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.regularMaterial)
                                        .frame(width: geometry.size.width - 50, height: 50)
                                    
                                    HStack {
                                        Image(systemName: spaces[index].spaceIcon)
                                        Text(spaces[index].spaceName)
                                    }
                                    .foregroundStyle(Color(hex: "4D4D4D"))
                                    .font(.system(size: 16, weight: .bold))
                                    .opacity(selectedSpaceIndex == index ? 1.0 : 0.4)
                                    .padding(.horizontal, 15)
                                }
                                .frame(width: geometry.size.width / 2, height: 50)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .contentShape(Rectangle())
                                .id(index)
                                .onAppear {
                                    if selectedSpaceIndex == index {
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
            .padding(.bottom)
        }.frame(height: 75)
    }

    
    private func handleDragChange(_ gesture: DragGesture.Value, for id: UUID) {
        offsets[id] = gesture.translation
        zIndexes[id] = 100
        var tilt = min(Double(abs(gesture.translation.width)) / 20, 15)
        if gesture.translation.width < 0 {
            tilt *= -1
        }
        tilts[id] = tilt
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value, for id: UUID) {
        zIndexes[id] = 1
        if abs(gesture.translation.width) > 100 {
            withAnimation {
                if gesture.translation.width < 0 {
                    offsets[id] = CGSize(width: -500, height: 0)
                } else {
                    offsets[id] = CGSize(width: 500, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        removeItem(id)
                    }
                }
            }
        } else {
            withAnimation {
                offsets[id] = .zero
                tilts[id] = 0.0
            }
        }
    }
    
    private func updateTabs() {
        var temporaryTabs = spaces[selectedSpaceIndex].tabUrls.map { (id: UUID(), url: $0) }
        tabs = temporaryTabs.reversed()
        pinnedTabs = spaces[selectedSpaceIndex].pinnedUrls.map { (id: UUID(), url: $0) }
        favoriteTabs = spaces[selectedSpaceIndex].favoritesUrls.map { (id: UUID(), url: $0) }
    }
    
    private func removeItem(_ id: UUID) {
        switch selectedTabsSection {
        case .tabs:
            if let index = tabs.firstIndex(where: { $0.id == id }) {
                tabs.remove(at: index)
                spaces[selectedSpaceIndex].tabUrls.remove(at: index)
            }
        case .pinned:
            if let index = pinnedTabs.firstIndex(where: { $0.id == id }) {
                pinnedTabs.remove(at: index)
                spaces[selectedSpaceIndex].pinnedUrls.remove(at: index)
            }
        case .favorites:
            if let index = favoriteTabs.firstIndex(where: { $0.id == id }) {
                favoriteTabs.remove(at: index)
                spaces[selectedSpaceIndex].favoritesUrls.remove(at: index)
            }
        }

        // Clean up UI elements associated with the tab
        withAnimation {
            offsets.removeValue(forKey: id)
            tilts.removeValue(forKey: id)
            zIndexes.removeValue(forKey: id)
        }
    }
    
    private func createTab(url: String) {
        let newTab = (id: UUID(), url: url)
        
        switch selectedTabsSection {
        case .tabs:
            tabs.append(newTab)
            spaces[selectedSpaceIndex].tabUrls.append(url)
        case .pinned:
            pinnedTabs.append(newTab)
            spaces[selectedSpaceIndex].pinnedUrls.append(url)
        case .favorites:
            favoriteTabs.append(newTab)
            spaces[selectedSpaceIndex].favoritesUrls.append(url)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            withAnimation {
                selectedTab = newTab
                fullScreenWebView = true
            }
        })
    }
    
    func fetchXML(searchRequest: String) {
        guard let url = URL(string: "https://toolbarqueries.google.com/complete/search?q=\(searchRequest.replacingOccurrences(of: " ", with: "+"))&output=toolbar&hl=en") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let xmlContent = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.xmlString = xmlContent
                }
            } else {
                print("Unable to convert data to string")
            }
        }.resume()
    }
    
    func formatXML(from input: String) -> [String] {
        var results = [String]()
        
        // Find all occurrences of 'data="' in the XML string
        var currentIndex = xmlString.startIndex
        while let startIndex = xmlString[currentIndex...].range(of: "data=\"")?.upperBound {
            let remainingSubstring = xmlString[startIndex...]
            
            // Find the end of the attribute value enclosed in quotation marks
            if let endIndex = remainingSubstring.range(of: "\"")?.lowerBound {
                let attributeValue = xmlString[startIndex..<endIndex]
                results.append(String(attributeValue))
                
                // Move to the next character after the found attribute value
                currentIndex = endIndex
            } else {
                break
            }
        }
        
        return results
    }
}

struct WebPreview: View {
    let namespace: Namespace.ID
    @State var url: String
    @State private var webTitle: String = ""
    
    @StateObject var settings = SettingsVariables()
    //@StateObject private var webViewModel = WebViewModel()
    
    var geo: GeometryProxy
    
    @State var faviconSize = CGFloat(20)
    
    @State var tab: (id: UUID, url: String)
    
    @State var webViewBackgroundColor: UIColor? = UIColor.white
    
    var body: some View {
        VStack {
#if !os(macOS)
            ZStack {
                Color.white.opacity(0.0001)
                
                WebViewMobile(urlString: url, title: $webTitle, webViewBackgroundColor: $webViewBackgroundColor)
                    .frame(width: geo.size.width - 50, height: 400)
                    .disabled(true)
                
            }
            .scaleEffect(0.5)
            .frame(width: geo.size.width / 2 - 25, height: 200) // Small size for tappable area
            .clipped()
            .cornerRadius(15)
            
            HStack {
                if settings.faviconLoadingStyle {
                    WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: faviconSize, height: faviconSize)
                            .cornerRadius(settings.faviconShape == "square" ? 0: settings.faviconShape == "squircle" ? 5: 100)
                            .padding(.leading, 5)
                        
                    } placeholder: {
                        LoadingAnimations(size: Int(faviconSize), borderWidth: 5.0)
                            .padding(.leading, 5)
                    }
                    .onSuccess { image, data, cacheType in
                        
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    
                } else {
                    AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: faviconSize, height: faviconSize)
                            .cornerRadius(settings.faviconShape == "square" ? 0: settings.faviconShape == "squircle" ? 5: 100)
                            .padding(.leading, 5)
                        
                    } placeholder: {
                        LoadingAnimations(size: Int(faviconSize), borderWidth: 5.0)
                            .padding(.leading, 5)
                    }
                    
                }
                
                Text(webTitle)
                    .foregroundStyle(Color.black)
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .lineLimit(1)
                
                Spacer()
            }
#endif
        }.matchedGeometryEffect(id: tab.id, in: namespace)
    }
}
