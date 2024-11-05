import SwiftUI

// Summit's main view (obviously.)
public struct SummitView: View {
    // Variable initialization, you still know the drill)
    private let appIcon: NSImage
    private let appName: String
    private let links: [ButtonLink]
    private let fields: [any SummitFieldItem]
    private let subHeading: String
    private let multiSubheading: MultiSubheading?
    private let windowWidth: CGFloat
    private let windowHeight: CGFloat
    private let footers: [Footer]
    public init(links: [ButtonLink] = [],
                fields: [any SummitFieldItem] = [],
                footers: [Footer] = [],
                footerLinks: [FooterLink] = [],
                subHeading: String = "",
                multiSubheading: MultiSubheading? = nil,
                windowWidth: CGFloat = 280,
                windowHeight: CGFloat = 425
    ) {
        // Automatic app icon fetching
        self.appIcon = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
        // Automatic app name fetching
        self.appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "This App"
        self.links = links
        self.fields = fields
        self.subHeading = subHeading
        self.multiSubheading = multiSubheading
        self.windowWidth = windowWidth
        self.windowHeight = windowHeight
        self.footers = footers
        
        // Crashes your app if you try to use both a subHeading AND a multiSubheading (I literally warn you of this in the readme, do better next time.)
        assert(subHeading.isEmpty || multiSubheading == nil, "Cannot use both subHeading and multiSubheading simultaneously")
    }
    
    // The big view.
    public var body: some View {
        ZStack {
            // Uses VisualEffectView's translucent background, across the whole window
            VisualEffectView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 5) {
                // Your beautiful app icon is displayed right here, at 150x150
                Image(nsImage: appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                // Big, bold, and selectable application name display
                Text(appName)
                    .font(.title)
                    .fontWeight(.bold)
                    .textSelection(.enabled)
                
                // Your subHeading (or multiSubheading, I don't judge) goes here
                if let duo = multiSubheading {
                    duo
                } else if !subHeading.isEmpty {
                    Text(subHeading)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .textSelection(.enabled)
                }
                
                // Manual padding addition (Since the subHeading is handled differently this time)
                Spacer()
                    .frame(height: 10)
                
                // All of your Fields and MultiFields are shown right here, no limit to how many you can have.
                Form {
                    ForEach(Array(fields.enumerated()), id: \.1.id) { _, field in
                        AnyView(field)
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
                
                // Your footers, with links or not, go right here, and you can have a total of 4 of them (combined)
                VStack {
                    ForEach(Array(footers.prefix(4)), id: \.content.id) { footer in
                        AnyView(footer.content)
                    }
                }
            }
            .padding()
            // Centers the window upon opening
            .onAppear {
                if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "about" }) {
                    window.center()
                }
            }
        }
        // Limits view sizing (as it shouldn't be resizable, your app has to cooperate with me here though by setting .windowResizability)
        .frame(width: windowWidth, height: windowHeight)
        // Uses the proper window dragging gesture extension (Only on macOS Sequoia and later!)
        .applyWindowDragGesture()
        // Disables window restoration using the 272nd extension of the day
        .willRestore(false)
        // Disables the "minimize window" button, as it isn't enabled on the actual About This Mac window
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
            for window in NSApplication.shared.windows {
                window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
            }
        })
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

// Labels used for Fields and MultiFields
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

// Sets up a structure for all footers (we're gonna be here for a while aren't we)
public struct Footer: ExpressibleByStringLiteral {
    let content: any SummitFooterItem
    public init(stringLiteral value: String) {
        self.content = TextFooter(label: value)
    }
    public init(text: String) {
        self.content = TextFooter(label: text)
    }
    // The only actual FooterLink related thing here.
    public init(label: String, url: URL) {
        self.content = FooterLink(label: label, url: url)
    }
    public init(unicodeScalarLiteral value: String) {
        self.content = TextFooter(label: value)
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.content = TextFooter(label: value)
    }
}

// Sets up a whole struct for all FooterLinks
public struct FooterLink: SummitFooterItem {
    public let id = UUID()
    let label: String
    let url: URL
    
    public var body: some View {
        Link(label, destination: url)
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .underline()
    }
}

// Sets up a whole struct for all REGULAR Footers with only text in them
public struct TextFooter: SummitFooterItem {
    public let id = UUID()
    let label: String
    
    public var body: some View {
        Text(label)
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }
}

// Common protocol for both Footer varieties
public protocol SummitFooterItem: View {
    var id: UUID { get }
}

// Common protocol for both Field varieties
public protocol SummitFieldItem: View {
    var id: UUID { get }
    var label: String { get }
}

// The actual struct for regular Fields to make it conform to SummitFieldItem
public struct Field: SummitFieldItem {
    public let id = UUID()
    public let label: String
    public let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        SummitLabel(label: label, value: value)
    }
}

// The new MultiSubheading struct for multiple values (Goodness gracious this is going to take forever)
public struct MultiSubheading: View {
    private let values: [Int: String]
    @State private var currentIndex: Int = 1
    
    public init(_ values: [Int: String]) {
        self.values = values
    }
    public init(values: String...) {
        var dict = [Int: String]()
        for (index, value) in values.enumerated() {
            dict[index + 1] = value
        }
        self.values = dict
    }
    public init(numbered values: (Int, String)...) {
        var dict = [Int: String]()
        for (index, value) in values {
            dict[index] = value
        }
        self.values = dict
    }
    private func nextIndex() -> Int {
        let sortedIndices = values.keys.sorted()
        guard let currentPosition = sortedIndices.firstIndex(of: currentIndex),
              let nextValue = sortedIndices[safe: currentPosition + 1] else {
            return sortedIndices.first ?? 1
        }
        return nextValue
    }
    public var body: some View {
        Text(values[currentIndex] ?? "")
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .onTapGesture {
                currentIndex = nextIndex()
            }
    }
}

// MultiField (Now with indefinite values and tons of other minor changes!)
public struct MultiField: SummitFieldItem {
    public let id = UUID()
    public let label: String
    private let values: [Int: String]
    @State private var currentIndex: Int = 1
    public init(label: String, values: [Int: String]) {
        self.label = label
        self.values = values
    }
    public init(label: String, values: String...) {
        self.label = label
        var dict = [Int: String]()
        for (index, value) in values.enumerated() {
            dict[index + 1] = value
        }
        self.values = dict
    }
    public init(label: String, numbered values: (Int, String)...) {
        self.label = label
        var dict = [Int: String]()
        for (index, value) in values {
            dict[index] = value
        }
        self.values = dict
    }
    private func nextIndex() -> Int {
        let sortedIndices = values.keys.sorted()
        guard let currentPosition = sortedIndices.firstIndex(of: currentIndex),
              let nextValue = sortedIndices[safe: currentPosition + 1] else {
            return sortedIndices.first ?? 1
        }
        return nextValue
    }
    public var body: some View {
        LabeledContent(label) {
            Text(values[currentIndex] ?? "")
                .foregroundStyle(.secondary)
                .onTapGesture {
                    currentIndex = nextIndex()
                }
        }
        .font(.subheadline)
    }
}

// Helper extension for safe array access <--- I do not know wtf that means
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
