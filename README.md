# HUD

HUD is framework to display a custom HUD. The HUD will be vertically and horizontally centered on a dimmed background in its own window on the current window scene.

## Usage

From a SwiftUI View

```swift
.hud(isPresented: $showHUD) {
    // Your HUD
}
```

From anywhere

```swift
// Present
HUD.present {
    // Your HUD
}

// Dismiss
HUD.dismiss()
```

## License

See [LICENSE](LICENSE)