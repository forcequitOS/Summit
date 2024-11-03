import SwiftUI

// The main view for Summit
public struct SummitView: View {
    // Variable initialization, you know the drill.
    private let appIcon: NSImage
    private let appName: String
    private let links: [ButtonLink]
    private let fields: [Field]
    private let selectableItems: [SelectableItem]
    private let minorText: String
    private let windowWidth: CGFloat
    private let windowHeight: CGFloat
    private let footers: [Footer]
    private let footerLinks: [FooterLink]

    public init(links: [ButtonLink] = [],
                fields: [Field] = [],
                selectableItems: [SelectableItem] = [],
                footers: [Footer] = [],
                footerLinks: [FooterLink] = [],
                minorText: String = "",
                windowWidth: CGFloat = 280,
                windowHeight: CGFloat = 425
    ) {
        // Auto app icon fetching
        self.appIcon = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
        // Auto app name fetching
        self.appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "This App"
        self.links = links
        self.fields = fields
        self.selectableItems = selectableItems
        self.minorText = minorText
        self.windowWidth = windowWidth
        self.windowHeight = windowHeight
        self.footers = footers
        self.footerLinks = footerLinks
    }

    // The big view.
    public var body: some View {
        ZStack {
            // Uses VisualEffectView's translucent background, across the whole window
            VisualEffectView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 5) {
                // App icon display, 150x150
                Image(nsImage: appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                // App name display, big and bold (and selectable!)
                Text(appName)
                    .font(.title)
                    .fontWeight(.bold)
                    .textSelection(.enabled)
                
                // Small text under the app name, optional of course
                Text(minorText)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .textSelection(.enabled)
                    .padding(.bottom, 10)
                
                // All of the main Fields and SelectableItems here
                Form {
                    ForEach(fields, id: \.label) { field in
                        SummitLabel(label: field.label, value: field.value)
                    }
                    ForEach(selectableItems.indices, id: \.self) { index in
                        selectableItems[index]
                    }
                }
                .padding(.bottom, 20)
                
                // All of the whopping 0-2 ButtonLinks go here, next to eachother
                HStack {
                    ForEach(links.prefix(2), id: \.url) { link in
                        Link(link.label, destination: link.url)
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.bottom, 10)
                
                // All of the footer text and footer links are here, 2 footer links max and 3 footers max
                VStack {
                    ForEach(footerLinks.prefix(2)) { footerLink in
                        Link(footerLink.label, destination: footerLink.url)
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .underline()
                    }
                    ForEach(footers.prefix(3)) { footer in
                        Text(footer.text)
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
            // Centers window upon starting
            .onAppear {
                if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "about" }) {
                    window.center()
                }
            }
        }
        // Limits window size (As it shouldn't be resizable)
        .frame(width: windowWidth, height: windowHeight)
        // Uses the proper window dragging gesture extension (Only on macOS Sequoia and later!)
        .applyWindowDragGesture()
        // Avoids restoring the window upon your app closing
        .willRestore(false)
    }
}

// Ahh, all the structs and extensions.
// Only allow WindowDragGesture (dragging window from anywhere) when running on macOS Sequoia or later
extension View {
    @ViewBuilder
    func applyWindowDragGesture() -> some View {
        if #available(macOS 15.0, *) {
            self.gesture(WindowDragGesture())
        } else {
            self
        }
    }
}

// Blurry translucent window background effect
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.state = .followsWindowActiveState
        effectView.material = .popover
        effectView.blendingMode = .behindWindow
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

// Labels used for the Fields
struct SummitLabel: View {
    let label: String
    let value: String

    var body: some View {
        LabeledContent(label) {
            Text(value)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .font(.subheadline)
    }
}

// Labels used for the very similar, SelectableItems
public struct SelectableItem: View {
    @State private var isSelected: Bool = false
    private let label: String
    private let valueOne: String
    private let valueTwo: String

    public init(label: String, valueOne: String, valueTwo: String) {
        self.label = label
        self.valueOne = valueOne
        self.valueTwo = valueTwo
    }

    public var body: some View {
        LabeledContent(label) {
            Text(isSelected ? valueTwo : valueOne)
                .foregroundStyle(.secondary)
                .onTapGesture {
                    isSelected.toggle()
                }
        }
        .font(.subheadline)
    }
}

// Disables window restoration behavior
struct WillRestore: ViewModifier {
    let restore: Bool

    func body(content: Content) -> some View {
    content
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification), perform: { output in
            let window = output.object as! NSWindow
            window.isRestorable = restore
        })
    }
}

// Helps with disabling window restoration behavior, or something like that
extension View {
    func willRestore(_ restoreState: Bool = true) -> some View {
        modifier(WillRestore(restore: restoreState))
    }
}

// Sets up a structure for all buttons
public struct ButtonLink: Identifiable {
    public let id = UUID()
    public let label: String
    public let url: URL

    public init(label: String, url: URL) {
        self.label = label
        self.url = url
    }
}

// Sets up a structure for all fields
public struct Field: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

// Sets up a structure for all footers (we're gonna be here for a while aren't we)
public struct Footer: Identifiable {
    public let id = UUID() // Ensure each custom field has a unique identifier
    public let text: String // Label for the field

    public init(text: String) {
        self.text = text
    }
}

// Sets up a structure for all linkable footers (Okay that wasn't too bad.)
public struct FooterLink: Identifiable {
    public let id = UUID() // Ensure each custom field has a unique identifier
    public let label: String // Label for the field
    public let url: URL

    public init(label: String, url: URL) {
        self.label = label
        self.url = url
    }
}
