# Summit
### Because everyone deserves great About screens.
<img src="https://github.com/forcequitOS/Summit/blob/main/Summit%20Demo.png?raw=true" alt="A small screenshot showcasing Summit's About Screen" width="35%">
Now you too can show off your amazing app icons while looking like a native Apple app!

**Requires macOS 13.0 Ventura or later.**

<sub>I'm sorry, macOS Monterey. Your time is over.</sub>

# Credits:
[r/SwiftUI](https://reddit.com/r/SwiftUI) - 100% helped me figure out how to align stuff properly, eternally grateful.

[ChatGPT](https://chatgpt.com) - Helped me figure out how to make this into a Swift Package, 95% of the other work was done by me

[Claude](https://claude.ai) - Helped me merge a lot of stuff together for the 1.1.0 update because I don't know what I'm doing lol

Various people on StackOverflow - Tons of stuff.

# Usage:

Here's a demo containing almost every single possible thing Summit is capable of, and the optimal way to implement it:

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
                    openWindow(id: "about")
                }, label: {
                    Text("About This App")
                })
            }
        }
        Window("About This App", id: "about") {
            SummitView(
                links: [
                    ButtonLink(label: "Visit Google...", url: URL(string: "https://google.com")!),
                    ButtonLink(label: "Visit Apple...", url: URL(string: "https://apple.com")!)
                ],
                fields: [
                    Field(label: "A Field", value: "A Value"),
                    MultiField(label: "A MultiField", values: "Click me!", "I change values", "Multiple times, even!", "Please stop now.", "I have a family."),
                    Field(label: "Mix and match", value: "Fields and MultiFields")
                ],
                footers: [
                    Footer(label: "Add links to your footers", url: URL(string: "https://example.com")!),
                    Footer(text: "Or just plain text like this"),
                    "Or even simpler, like this!"
                ],
                multiSubheading: MultiSubheading(values: "I'm a multiSubheading", "That was cool", "Okay, you can stop now."),
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

Links / ButtonLinks: Buttons. You can have up to two. Each has a label and a URL to point to.

Fields: These are the core of everything. Each has a label and a value.

MultiFields: A variety of field, they have a constant label, but they can change values when clicked. You define the amount of values now!

Footers: These contain either text or a link to a webpage (your choice) and you can have up to 4 of them

subHeading: It's just the small text that displays underneath your app's name. You can use one of these, OR one MultiSubheading, not both.

MultiSubheading: A subHeading that changes values when clicked, similar to a MultiField in purpose. Remember, as stated above, only one subHeading OR a MultiHeading, you can't have both.

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

Enjoy. Now you can be as lazy as you wish.

All of these should work 100% fine with Summit, I just didn't want to include this logic all built in as it would make the package larger and some developers may not want or need it.

