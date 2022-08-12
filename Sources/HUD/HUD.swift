//
//  HUD.swift
//  HUD
//
//  Created by David Walter on 07.08.22.
//

import SwiftUI
import WindowSceneReader
import os

public struct HUD {
    var windowScene: UIWindowScene
    
    /// Create a HUD on the given window scene. If no window scene is provided the first connected window scene is used.
    ///
    /// - Parameter windowScene: The `UIWindowScene` to create the `HUD` for
    public init?(windowScene: UIWindowScene? = nil) {
        guard let windowScene = windowScene ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            os_log("No window scene was provided and no connected window scene was found.", type: .error)
            return nil
        }
        
        self.windowScene = windowScene
    }
    
    /// Present the `HUD`
    ///
    /// - Parameters:
    ///     - style: The user interface style of the view
    ///     - content: Some `View` to display as HUD
    public func present<Content>(style: UIUserInterfaceStyle = .unspecified,
                                 content: @escaping () -> Content) where Content: View {
        HUD.present(on: windowScene, style: style, content: content)
    }
    
    /// Dismiss the `HUD`
    ///
    /// - Parameter animated: Wether to dismiss the `HUD` animated or not
    public func dismiss(animated: Bool = true) {
        HUD.dismiss(on: windowScene, animated: animated)
    }
    
    // MARK: - Static
    
    /// Present a `HUD` on the given window scene
    ///
    /// - Parameters:
    ///     - windowScene: The window scene to display the HUD on
    ///     - style: The user interface style of the view
    ///     - content: Some `View` to display as HUD
    public static func present<Content>(on windowScene: UIWindowScene,
                                        style: UIUserInterfaceStyle = .unspecified,
                                        content: @escaping () -> Content) where Content: View {
        HUDWindow(windowScene: windowScene, style: style)
            .present {
                HUDView(content: content)
            }
    }
    
    /// Dismiss a `HUD` on the given window scene
    ///
    /// - Parameters:
    ///     - windowScene: The window scene to dismiss the HUD on
    ///     - animated: Wether to dismiss the `HUD`s animated or not  
    public static func dismiss(on windowScene: UIWindowScene,
                               animated: Bool = true) {
        HUDWindow.dismiss(on: windowScene, animated: animated)
    }
    
    /// Present a `HUD` on the first connected window scene
    ///
    /// - Parameters:
    ///     - style: The user interface style of the view
    ///     - content: Some `View` to display as HUD
    ///
    /// No `HUD` will be displayed if no connected window scene is found
    public static func present<Content>(style: UIUserInterfaceStyle = .unspecified,
                                        content: @escaping () -> Content) where Content: View {
        HUD()?.present(style: style, content: content)
    }
    
    /// Dismiss all presented `HUD`s
    ///
    /// - Parameter animated: Wether to dismiss the `HUD`s animated or not
    public static func dismiss(animated: Bool = true) {
        HUDWindow.dismiss(animated: animated)
    }
}

extension View {
    /// Present a `HUD` on the given window scene
    ///
    /// - Parameters:
    ///     - isPresented: Wether to display the HUD or hide
    ///     - style: The user interface style of the view
    ///     - content: Some `View` to display as HUD
    public func hud<Content>(isPresented: Binding<Bool>,
                             style: UIUserInterfaceStyle = .unspecified,
                             content: @escaping () -> Content) -> some View where Content: View {
        background {
            WindowSceneReader { windowScene in
                hud(isPresented: isPresented, on: windowScene, style: style, content: content)
            }
        }
    }
    
    /// Present a `HUD` on the given window scene
    ///
    /// - Parameters:
    ///     - isPresented: Wether to display the HUD or hide 
    ///     - windowScene: The window scene to display the HUD on
    ///     - style: The user interface style of the view
    ///     - content: Some `View` to display as HUD
    public func hud<Content>(isPresented: Binding<Bool>,
                             on windowScene: UIWindowScene,
                             style: UIUserInterfaceStyle = .unspecified,
                             content: @escaping () -> Content) -> some View where Content: View {
        modifier(HUDViewModifier(isPresented: isPresented, windowScene: windowScene, style: style, hudContent: content))
    }
}

struct HUDViewModifier<HUDContent>: ViewModifier where HUDContent: View {
    @Binding var isPresented: Bool
    var window: HUDWindow
    var style: UIUserInterfaceStyle
    @ViewBuilder var hudContent: () -> HUDContent
    
    init(isPresented: Binding<Bool>, windowScene: UIWindowScene, style: UIUserInterfaceStyle, @ViewBuilder hudContent: @escaping () -> HUDContent) {
        self._isPresented = isPresented
        self.window = HUDWindow(windowScene: windowScene, style: style, isPresented: isPresented)
        self.style = style
        self.hudContent = hudContent
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if isPresented {
                    present()
                }
            }
            .onChange(of: isPresented) { isPresented in
                if isPresented {
                    present()
                } else {
                    window.dismiss(animated: true)
                }
            }
    }
    
    func present() {
        window.present {
            HUDView(content: hudContent)
        }
    }
}
