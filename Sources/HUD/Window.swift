//
//  Window.swift
//  HUD
//
//  Created by David Walter on 07.08.22.
//

import UIKit
import SwiftUI
import os

class HUDWindow: UIWindow {
    static var presented: [UIWindowScene: HUDWindow] = [:]
    
    var isPresented: Binding<Bool>
    
    init(windowScene: UIWindowScene, style: UIUserInterfaceStyle, isPresented: Binding<Bool> = .constant(true)) {
        self.isPresented = isPresented
        super.init(windowScene: windowScene)
        
        self.rootViewController = UIViewController(nibName: nil, bundle: nil)
        self.windowLevel = .alert
        self.backgroundColor = .clear
        self.overrideUserInterfaceStyle = style
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        isPresented.wrappedValue = false
    }
    
    func present<Content>(style: UIUserInterfaceStyle = .unspecified,
                          @ViewBuilder _ view: () -> Content) where Content: View {
        guard HUDWindow.presented[windowScene!] == nil else {
            os_log("Attempt to present HUD while current window is already presenting another HUD.", type: .error)
            return
        }
        
        HUDWindow.presented[windowScene!] = self
        
        let hostingController = UIHostingController(rootView: view())
        hostingController.view.backgroundColor = .clear
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.modalPresentationStyle = .fullScreen
        
        // subviews.forEach { $0.isHidden = true }
        makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.rootViewController?.present(hostingController, animated: true)
        }
    }
    
    func dismiss(animated: Bool) {
        if animated, let viewController = rootViewController {
            viewController.dismiss(animated: true) { [weak self] in
                self?.isPresented.wrappedValue = false
                self?.isHidden = true
                
                if let windowScene = self?.windowScene {
                    HUDWindow.presented[windowScene] = nil
                }
            }
        } else {
            isPresented.wrappedValue = false
            isHidden = true
            
            if let windowScene = windowScene {
                HUDWindow.presented[windowScene] = nil
            }
        }
    }
    
    static func dismiss(on windowScene: UIWindowScene, animated: Bool) {
        guard let window = HUDWindow.presented[windowScene] else { return }
        window.dismiss(animated: animated)
    }
    
    static func dismiss(animated: Bool) {
        HUDWindow.presented.keys.forEach { windowScene in
            HUDWindow.dismiss(on: windowScene, animated: animated)
        }
    }
}
