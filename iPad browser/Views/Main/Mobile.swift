//
//  TestingView.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import UIKit
import WebKit
import Combine
import FaviconFinder
import SDWebImage
import SDWebImageSwiftUI
import SwiftData



struct Mobile: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    // WebView Handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@State private var spaces = ["Home", "Space 2"]
    @State private var spaceIcons: [String: String]? = [:]
    
    @State private var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @State private var hoverTab = WKWebView()
    
    @State private var showSettings = false
    @State private var changeColorSheet = false
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    @State private var textColor: Color = Color.white
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @State private var presentIcons = false
    
    // Hover Effects
    @State private var hoverTinySpace = false
    
    @State private var hoverSidebarButton = false
    @State private var hoverPaintbrush = false
    @State private var hoverReloadButton = false
    @State private var hoverForwardButton = false
    @State private var hoverBackwardButton = false
    @State private var hoverNewTab = false
    @State private var settingsButtonHover = false
    @State private var hoverNewTabSection = false
    
    @State private var hoverSpaceIndex = 1000
    @State private var hoverSpace = ""
    
    @State private var hoverSidebarSearchField = false
    
    @State private var hoverCloseTab = WKWebView()
    
    @State private var spaceIconHover = false
    
    // Animations and Gestures
    @State private var reloadRotation = 0
    @State private var draggedTab: WKWebView?
    
    // Selection States
    @State private var tabBarShown = false
    @State private var commandBarShown = false
    
    @State private var changingIcon = ""
    //@State private var hideSidebar = false
    @AppStorage("hideSidebar") var hideSidebar = false
    
    @State private var searchInSidebar = ""
    @State private var newTabSearch = ""
    @State private var newTabSaveSearch = ""
    
    @State private var currentTabNum = 0
    
    @State private var selectedIndex: Int? = 0
    
    @FocusState private var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    //@State var selectedSpaceIndex = 0
    
    @State var loadingAnimationToggle = false
    @State var offset = 0.0
    @State var loadingRotation = 0
    
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("showBorder") var showBorder = true
    
    @State private var inspectCode = ""
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    @State private var selectedTabLocation = "tabs"
    
    // Other Stuff
    @State private var screenWidth = UIScreen.main.bounds.width
    
    @State private var hoveringSidebar = false
    @State private var tapSidebarShown = false
    
    @State var commandBarCollapseHeightAnimation = false
    @State var commandBarSearchSubmitted = false
    @State var commandBarSearchSubmitted2 = false
    
    @State var auraTab = ""
    
    @State var initialLoadDone = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if spaces.count > 0 {
                    ZStack {
                        ZStack {
                            if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                                //if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                //}
                            }
                            else {
                                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                            }
                            
                            if prefferedColorScheme == "dark" || (prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                Color.black.opacity(0.5)
                            }
                            
                            HStack(spacing: 0) {
                                if sidebarLeft {
                                    Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                                        .animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? -320: 0).padding(.trailing, hideSidebar ? 0: 10)
                                        .padding(0)
                                }
                                
                                ZStack {
                                    Color.white
                                        .opacity(0.4)
                                        .cornerRadius(10)
                                    
                                    
                                    //MARK: - WebView
                                    if selectedTabLocation == "favoriteTabs" {
                                        WebView(navigationState: favoritesNavigationState)
                                            .cornerRadius(10)
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .trim(from: 0.25 + offset, to: 0.5 + offset)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        //.foregroundStyle(Color.white)
                                            .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                                            .opacity(favoritesNavigationState.selectedWebView?.isLoading ?? false ? 1.0: 0.0)
                                            .animation(.default, value: favoritesNavigationState.selectedWebView?.isLoading ?? false)
                                            .blur(radius: 5)
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .trim(from: 0.25 + offset, to: 0.5 + offset)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .rotation(Angle(degrees: 180))
                                        //.foregroundStyle(Color.white)
                                            .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                                            .opacity(favoritesNavigationState.selectedWebView?.isLoading ?? false ? 1.0: 0.0)
                                            .animation(.default, value: favoritesNavigationState.selectedWebView?.isLoading ?? false)
                                            .blur(radius: 5)
                                        
                                            .onReceive(rotationTimer) { thing in
                                                if offset == 0.5 {
                                                    offset = 0.0
                                                    withAnimation(.linear(duration: 1.5)) {
                                                        offset = 0.5
                                                    }
                                                }
                                                else {
                                                    withAnimation(.linear(duration: 1.5)) {
                                                        offset = 0.5
                                                    }
                                                }
                                            }
                                    }
                                    if selectedTabLocation == "tabs" {
                                        WebView(navigationState: navigationState)
                                            .cornerRadius(10)
                                        
                                        
                                        
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .trim(from: 0.25 + offset, to: 0.5 + offset)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        //.foregroundStyle(Color.white)
                                            .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                                            .opacity(navigationState.selectedWebView?.isLoading ?? false ? 1.0: 0.0)
                                            .animation(.default, value: navigationState.selectedWebView?.isLoading ?? false)
                                            .blur(radius: 5)
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .trim(from: 0.25 + offset, to: 0.5 + offset)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .rotation(Angle(degrees: 180))
                                        //.foregroundStyle(Color.white)
                                            .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                                            .opacity(navigationState.selectedWebView?.isLoading ?? false ? 1.0: 0.0)
                                            .animation(.default, value: navigationState.selectedWebView?.isLoading ?? false)
                                            .blur(radius: 5)
                                        
                                            .onReceive(rotationTimer) { thing in
                                                if offset == 0.5 {
                                                    offset = 0.0
                                                    withAnimation(.linear(duration: 1.5)) {
                                                        offset = 0.5
                                                    }
                                                }
                                                else {
                                                    withAnimation(.linear(duration: 1.5)) {
                                                        offset = 0.5
                                                    }
                                                }
                                            }
                                    }
                                    
                                    if selectedTabLocation == "pinnedTabs" {
                                        WebView(navigationState: pinnedNavigationState)
                                            .cornerRadius(10)
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .trim(from: 0.25 + offset, to: 0.5 + offset)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        //.foregroundStyle(Color.white)
                                            .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                                            .opacity(pinnedNavigationState.selectedWebView?.isLoading ?? false ? 1.0: 0.0)
                                            .animation(.default, value: pinnedNavigationState.selectedWebView?.isLoading ?? false)
                                            .blur(radius: 5)
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .trim(from: 0.25 + offset, to: 0.5 + offset)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .rotation(Angle(degrees: 180))
                                        //.foregroundStyle(Color.white)
                                            .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                                            .opacity(pinnedNavigationState.selectedWebView?.isLoading ?? false ? 1.0: 0.0)
                                            .animation(.default, value: pinnedNavigationState.selectedWebView?.isLoading ?? false)
                                            .blur(radius: 5)
                                        
                                            .onReceive(rotationTimer) { thing in
                                                if offset == 0.5 {
                                                    offset = 0.0
                                                    withAnimation(.linear(duration: 1.5)) {
                                                        offset = 0.5
                                                    }
                                                }
                                                else {
                                                    withAnimation(.linear(duration: 1.5)) {
                                                        offset = 0.5
                                                    }
                                                }
                                            }
                                    }
                                    
                                    if auraTab == "dashboard" {
                                        Dashboard(startHexSpace: spaces[selectedSpaceIndex].startHex, endHexSpace: spaces[selectedSpaceIndex].endHex)
                                            .cornerRadius(10)
                                            .clipped()
                                    }
                                    
                                    Spacer()
                                        .frame(width: 20)
                                }.padding(0)
                                //.animation(.default)
                                
                                if !sidebarLeft {
                                    Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                                    
                                        .animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? 320: 0).padding(.leading, hideSidebar ? 0: 10)
                                        .padding(0)
                                }
                            }
                            .onAppear {
                                if let savedStartColor = getColor(forKey: "startColorHex") {
                                    startColor = savedStartColor
                                }
                                if let savedEndColor = getColor(forKey: "endColorHex") {
                                    endColor = savedEndColor
                                }
                                if let savedTextColor = getColor(forKey: "textColorHex") {
                                    textColor = savedTextColor
                                }
                                
                                spaceIcons = UserDefaults.standard.dictionary(forKey: "spaceIcons") as? [String: String]
                            }
                            
                            if hideSidebar {
                                HStack {
                                    if !sidebarLeft {
                                        Spacer()
                                    }
                                    
                                    ZStack {
                                        Color.white.opacity(0.00001)
                                            .frame(width: 35)
                                            .onTapGesture {
                                                tapSidebarShown = true
                                                
                                            }
                                        
                                        HStack {
                                            
                                            Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                                                .padding(15)
                                                .background(content: {
                                                    if sidebarLeft {
                                                        LinearGradient(colors: [startColor, Color(hex: averageHexColor(hex1: startHex, hex2: endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                            .opacity(1.0)
                                                        if selectedSpaceIndex < spaces.count {
                                                            if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                                                LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: averageHexColor(hex1: spaces[selectedSpaceIndex].startHex, hex2: spaces[selectedSpaceIndex].endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                            }
                                                        }
                                                    } else {
                                                        LinearGradient(colors: [Color(hex: averageHexColor(hex1: startHex, hex2: endHex)), endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                            .opacity(1.0)
                                                        if selectedSpaceIndex < spaces.count {
                                                            if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                                                LinearGradient(colors: [Color(hex: averageHexColor(hex1: spaces[selectedSpaceIndex].startHex, hex2: spaces[selectedSpaceIndex].endHex)), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                            }
                                                        }
                                                    }
                                                    if prefferedColorScheme == "dark" || (prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                                        Color.black.opacity(0.5)
                                                    }
                                                })
                                                .frame(width: 300)
                                                .cornerRadius(10)
                                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                                            
                                            Spacer()
                                        }.padding(40)
                                            .padding(.leading, 30)
                                            .frame(width: hoveringSidebar || tapSidebarShown ? 350: 0)
                                            .offset(x: hoveringSidebar || tapSidebarShown ? 0: sidebarLeft ? -350: 300)
                                            .clipped()
                                        
                                    }.onHover(perform: { hovering in
                                        if hovering {
                                            hoveringSidebar = true
                                        }
                                        else {
                                            hoveringSidebar = false
                                        }
                                    })
                                    
                                    if sidebarLeft {
                                        Spacer()
                                    }
                                }.animation(.default)
                            }
                        }
                        .onTapGesture {
                            if tabBarShown || commandBarShown {
                                tabBarShown = false
                                commandBarShown = false
                            }
                            tapSidebarShown = false
                        }
                        
                        //MARK: - Tabbar
                        if tabBarShown {
                            CommandBar(commandBarText: $newTabSearch, searchSubmitted: $commandBarSearchSubmitted, collapseHeightAnimation: $commandBarCollapseHeightAnimation)
                                .onChange(of: commandBarSearchSubmitted) { thing in
                                    
                                    if !newTabSearch.starts(with: "aura://") {
                                        auraTab = ""
                                        navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: newTabSearch))!))
                                    }
                                    else {
                                        if newTabSearch.contains("dashboard") {
                                            auraTab = "dashboard"
                                            selectedTabLocation = ""
                                        }
                                    }
                                    
                                    tabBarShown = false
                                    commandBarSearchSubmitted = false
                                    newTabSearch = ""
                                    
                                    print("Saving Tabs")
                                    
                                    Task {
                                        do {
                                            try await modelContext.save()
                                        }
                                        catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    
                                    saveSpaceData()
                                }
                        }
                        else if commandBarShown {
                            CommandBar(commandBarText: $searchInSidebar, searchSubmitted: $commandBarSearchSubmitted2, collapseHeightAnimation: $commandBarCollapseHeightAnimation)
                                .onChange(of: commandBarSearchSubmitted) { thing in
                                    if selectedTabLocation == "tabs" {
                                        navigationState.currentURL = URL(string: formatURL(from: newTabSearch))!
                                        
                                        saveSpaceData()
                                    }
                                    
                                    tabBarShown = false
                                    commandBarSearchSubmitted = false
                                    newTabSearch = ""
                                }
                        }
                    }
                    .onChange(of: selectedSpaceIndex, {
                        if initialLoadDone {
                            navigationState.webViews.removeAll()
                            
                            var reloadAuraTabs = auraTab
                            auraTab = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
                                auraTab = reloadAuraTabs
                            }
                            
                            if selectedSpaceIndex < spaces.count {
                                if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                    startHex = spaces[selectedSpaceIndex].startHex
                                    endHex = spaces[selectedSpaceIndex].startHex
                                    
                                    startColor = Color(hex: spaces[selectedSpaceIndex].startHex)
                                    endColor = Color(hex: spaces[selectedSpaceIndex].endHex)
                                }
                            }
                            
                            UserDefaults.standard.setValue(selectedSpaceIndex, forKey: "savedSelectedSpaceIndex")
                        }
                    })
                    .onChange(of: navigationState.webViews, {
                        saveSpaceData()
                        print("Saving navigationState")
                    })
                    .onChange(of: pinnedNavigationState.webViews, {
                        saveSpaceData()
                        print("Saving pinnedNavigationState")
                    })
                    .onChange(of: favoritesNavigationState.webViews, {
                        saveSpaceData()
                        print("Saving favoritesNavigationState")
                    })
                    .onAppear() {
                        if UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex") > spaces.count - 1 {
                            selectedSpaceIndex = 0
                        }
                        else {
                            selectedSpaceIndex = UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex")
                        }
                        
                        if selectedSpaceIndex < spaces.count {
                            if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                startHex = spaces[selectedSpaceIndex].startHex
                                endHex = spaces[selectedSpaceIndex].startHex
                                
                                startColor = Color(hex: spaces[selectedSpaceIndex].startHex)
                                endColor = Color(hex: spaces[selectedSpaceIndex].endHex)
                            }
                        }
                        
                        for space in spaces {
                            if space.spaceName == currentSpace {
                                for tab in space.tabUrls {
                                    navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://figma.com")!))
                                }
                                for tab in space.pinnedUrls {
                                    pinnedNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://thebrowser.company")!))
                                }
                                for tab in space.favoritesUrls {
                                    favoritesNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://arc.net")!))
                                }
                            }
                        }
                        navigationState.selectedWebView = nil
                        pinnedNavigationState.selectedWebView = nil
                        favoritesNavigationState.selectedWebView = nil
                        
                        initialLoadDone = true
                    }
                }
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .fill(.thinMaterial)
                            .frame(height: 100)
                        
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(width: geo.size.width - 50, height: 50)
                                
                                Text(selectedTabLocation == "tabs" ? navigationState.currentURL?.absoluteStringWithoutScheme ?? "": selectedTabLocation == "pinned" ? pinnedNavigationState.currentURL?.absoluteStringWithoutScheme ?? "": favoritesNavigationState.currentURL?.absoluteStringWithoutScheme ?? "")
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                }.ignoresSafeArea()
            }
        }.task {
            if spaces.count <= 0 {
                await modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                
                do {
                    try await modelContext.save()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func saveSpaceData() {
        let savingTodayTabs = navigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingPinnedTabs = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingFavoriteTabs = favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
        
        if !spaces.isEmpty {
            print("Saving Today Tabs: \(savingTodayTabs)")
            spaces[selectedSpaceIndex].tabUrls = savingTodayTabs
            print(spaces[selectedSpaceIndex].tabUrls)
            spaces[selectedSpaceIndex].pinnedUrls = savingPinnedTabs
            spaces[selectedSpaceIndex].favoritesUrls = savingFavoriteTabs
        }
        else {
            modelContext.insert(SpaceStorage(spaceIndex: 0, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: savingTodayTabs))
        }
        
        Task {
            do {
                try await modelContext.save()
                print("modelContext Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
