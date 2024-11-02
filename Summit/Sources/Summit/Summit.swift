import SwiftUI

public struct SummitView: View {
    private let appIcon: NSImage
    private let appName: String
    private let links: [LinkInfo]
    private let customFields: [CustomField]

    public init(links: [LinkInfo] = [],
                customFields: [CustomField] = []) {
        self.appIcon = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
        self.appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
        self.links = links
        self.customFields = customFields
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Image(nsImage: appIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text(appName)
                .font(.title)
                .fontWeight(.bold)
                .textSelection(.enabled)
            
            Form {
                ForEach(customFields, id: \.label) { field in
                    SummitLabel(label: field.label, value: field.value)
                }
            }
            .padding(.bottom, 10)
            
            HStack {
                ForEach(links, id: \.url) { link in
                    Link(link.text, destination: link.url)
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}

// Only allow WindowDragGesture (dragging window from anywhere) when running on macOS Sequoia, won't have to worry about this soon.
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
// Blurred translucent window background effect
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
// Labels for about screen
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
// Helps with disabling window restoration behavior
extension View {
    func willRestore(_ restoreState: Bool = true) -> some View {
        modifier(WillRestore(restore: restoreState))
    }
}
