//
//  navigationState.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/28/24.
//

import SwiftUI
import WebKit

class NavigationState : NSObject, WKNavigationDelegate, WKUIDelegate, ObservableObject {
    @Published var currentURL : URL?
    @Published var webViews : [WKWebView] = []
    @Published var selectedWebView : WKWebView? = nil
    @Published var selectedWebViewTitle: String = ""
    
    override init() {
        super.init()
    }
    
    @discardableResult func createNewWebView(withRequest request: URLRequest) -> WKWebView {
        let wv = WKWebView()
        if UIDevice.current.userInterfaceIdiom == .phone {
            wv.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"
        }
        else {
            wv.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        }
        wv.navigationDelegate = self
        wv.uiDelegate = self
        webViews.append(wv)
        selectedWebView = wv
        wv.load(request)

        return wv
    }
    
    func webView(_ webView: WKWebView!, createWebViewWith configuration: WKWebViewConfiguration!, for navigationAction: WKNavigationAction!, windowFeatures: WKWindowFeatures!) -> WKWebView! {
        if navigationAction.targetFrame == nil {
            createNewWebView(withRequest: navigationAction.request)
        }
        return nil
    }
}
