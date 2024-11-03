# Summit
### Because everyone deserves great About screens.
<img src="https://github.com/forcequitOS/Summit/blob/main/Summit%20Demo.png?raw=true" alt="A small screenshot showcasing Summit's About Screen" width="35%">
Now you too can show off your amazing app icons while looking like a native Apple app!

Requires macOS 14.0 Sonoma or later

<sub>I'm 90% sure I could've adapted it to support macOS Ventura as well, but even Sonoma is pushing it with compatibility checks. macOS Monterey is also probably something I could have added support for if I felt like it.</sub>

# Credits:
[r/SwiftUI](https://reddit.com/r/SwiftUI) - 100% helped me figure out how to align stuff properly, eternally grateful.

[ChatGPT](https://chatgpt.com) - Helped me figure out how to make this into a Swift Package, 95% of the other work was done by me

Various people on StackOverflow - Tons of stuff.

# Usage:

Here's a demo containing every single possible thing Summit is capable of, and the optimal way to implement it:

```
import SwiftUI
import Summit

@main
struct Summit_DemoApp: App {
    @Environment(\.openWindow) private var openWindow
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    // Open the "about" window
                    openWindow(id: "about")
                }, label: {
                    Text("About This App")
                })
            }
        }
        Window("About This App", id: "about") {
            SummitView(
                links: [
                    ButtonLink(label: "Example Link 1", url: URL(string: "https://example.com")!),
                    ButtonLink(label: "Example Link 2", url: URL(string: "https://example.com/")!)
                ],
                fields: [
                    Field(label: "Field 1", value: "Value 1"),
                    Field(label: "Repeat This!", value: "Truly.")
                ],
                selectableItems: [
                    SelectableItem(label: "Version", valueOne: "Version", valueTwo: "Version (Build)"),
                ],
                footers: [
                    Footer(text: "© Your Name 2024"),
                    Footer(text: "All rights reserved!")
                ],
                footerLinks: [
                    FooterLink(label: "All Code Licenses", url: URL(string: "https://example.com")!)
                ],
                minorText: "Crazy.",
                windowWidth: 280,
                windowHeight: 425
            )
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
```

# Okay so what is everything?

Links: Buttons. You can have up to two. Each has a label and a URL to point to.

Fields: These are the core of everything. Each has a label and a value.

SelectableItems: These are Fields, except instead of having selectable text, when you click them, they change values. Useful for versions with build numbers.

Footers: These only contain text and are displayed at the bottom of the about window, you can have up to three of these.

FooterLinks: These look like footers, but are actually links. They're underlined, and require a label and URL value. You can have up to two of those.

minorText: It's just the small text that displays underneath your app name

windowWidth and windowHeight: Self explanatory.

# Do I need to provide my app name and icon manually?

No! Summit automatically gets them for you.

# What if I want the version to automatically be filled in?

### App Version
```
var appVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown Version"
}
```

### App Build
```
var appBuild: String? {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
}
```

### Xcode Version
```
var xcodeVersion: String {
    guard let dtxcodeString = Bundle.main.object(forInfoDictionaryKey: "DTXcode") as? String,
          let dtxcode = Int(dtxcodeString) else { return "Unknown" }
    let major = dtxcode / 100
    let minor = (dtxcode % 100) / 10
    return "\(major).\(minor)"
}
```

### Xcode Build

```
var xcodeBuild: String {
    Bundle.main.object(forInfoDictionaryKey: "DTXcodeBuild") as? String ?? "???"
}
```

Enjoy.

All of these should work 100% fine with Summit, I just didn't want to include this logic all built in as it would make the package larger and some developers may not want or need it.

