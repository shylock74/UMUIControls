//
//  UMUIAbout.swift
//  UMUIControls
//
//  A custom About dialog view with dynamic text typing animations,
//  styled with a premium modern glassmorphic look, and completely self-contained.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

/// A premium, self-contained About view with dynamic cyclic typing text effects.
/// Fits a standard width of 960 pixels and adapts its height automatically to the content.
public struct UMUIAbout: View {
    
    public let title: String
    public let image: Image
    public let texts: [String]
    public let copyrightText: String
    
    /// Creates a new About view.
    /// - Parameters:
    ///   - title: The name of the application.
    ///   - image: The Image view representing the application's logo/banner.
    ///   - textList: An array of taglines or descriptions to cycle through.
    ///   - copyright: Optional custom copyright text. If nil, auto-generates using the current year and bundle info.
    public init(
        title: String,
        image: Image,
        textList: [String],
        copyright: String? = nil
    ) {
        self.title = title
        self.image = image
        self.texts = textList
        
        if let copyright = copyright {
            self.copyrightText = copyright
        } else {
            let year = Calendar.current.component(.year, from: Date())
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            self.copyrightText = "© \(year) Ulti.Media [\(version) (\(build))]"
        }
    }
    
    /// Creates a new About view specifying an image name.
    /// - Parameters:
    ///   - title: The name of the application.
    ///   - imageName: The name of the image asset.
    ///   - textList: An array of taglines or descriptions to cycle through.
    ///   - copyright: Optional custom copyright text.
    public init(
        title: String,
        imageName: String,
        textList: [String],
        copyright: String? = nil
    ) {
        self.init(
            title: title,
            image: Image(imageName),
            textList: textList,
            copyright: copyright
        )
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if #available(macOS 12.0, *) {
                Text(title)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                Text(title)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(.primary)
            }
            
            // App Logo / Banner
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            
            // Dynamic Typing Slogans
            UMRollingThreeLinesView(texts: texts)
                .frame(height: 80, alignment: .topLeading)
            
            // Spacer to replicate UMVSpacer(10)
            Spacer()
                .frame(height: 10)
            
            // Copyright & Build / Version
            UMUICaptionGrayText(copyrightText)
        }
        .padding(32)
        .frame(width: 960)
        .background(
            ZStack {
                // Sleek dynamic material that works elegantly in light/dark modes
                #if os(macOS)
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                #else
                Color(white: 0.1)
                #endif
                
                // Subtle premium ambient light overlay based on active accent color
                RadialGradient(
                    colors: [Color.accentColor.opacity(0.08), Color.clear],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 700
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Native Windows Launcher (macOS)

#if os(macOS)
public extension UMUIAbout {
    
    /// Internal reference to ensure only one standalone About window remains active.
    private static var activeWindow: NSWindow?
    
    /// Opens the UMUIAbout view in a standalone modal-like, non-resizable macOS window.
    /// If the window is already open, it is brought to the front.
    ///
    /// - Parameters:
    ///   - appName: The name of the application to display as the title.
    ///   - image: The image / logo to display.
    ///   - textList: An array of strings that cycle with the typing animation.
    ///   - copyright: An optional copyright override.
    static func show(
        appName: String,
        image: Image,
        textList: [String],
        copyright: String? = nil
    ) {
        DispatchQueue.main.async {
            if let window = activeWindow {
                window.makeKeyAndOrderFront(nil)
                return
            }
            
            let aboutView = UMUIAbout(
                title: appName,
                image: image,
                textList: textList,
                copyright: copyright
            )
            
            let hostingController = NSHostingController(rootView: aboutView)
            
            // Create a window with title and close buttons
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 960, height: 200),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            window.title = "About \(appName)"
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden // Premium minimal presentation
            window.isMovableByWindowBackground = true
            window.isReleasedWhenClosed = false
            
            // Set the content view controller
            window.contentViewController = hostingController
            
            // Force layout pass to calculate target height
            hostingController.view.setFrameSize(NSSize(width: 960, height: CGFloat.greatestFiniteMagnitude))
            hostingController.view.layoutSubtreeIfNeeded()
            
            let fittingSize = hostingController.view.fittingSize
            let targetHeight = fittingSize.height > 0 ? fittingSize.height : 450
            
            window.setContentSize(NSSize(width: 960, height: targetHeight))
            window.minSize = NSSize(width: 960, height: targetHeight)
            window.maxSize = NSSize(width: 960, height: targetHeight)
            
            window.center()
            window.makeKeyAndOrderFront(nil)
            
            activeWindow = window
            
            // Observe window close to clean up activeWindow reference
            NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { _ in
                activeWindow = nil
            }
        }
    }
    
    /// Opens the UMUIAbout view in a standalone macOS window, specifying an image by its name.
    static func show(
        appName: String,
        imageName: String,
        textList: [String],
        copyright: String? = nil
    ) {
        show(
            appName: appName,
            image: Image(imageName),
            textList: textList,
            copyright: copyright
        )
    }
}

/// A helper view bridging AppKit's NSVisualEffectView to SwiftUI.
internal struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
#endif

// MARK: - Typing & Animation Subviews

struct RollingText: Identifiable, Equatable {
    let id: UUID
    let text: String
    var shouldType: Bool
}

struct UMRollingThreeLinesView: View {
    let texts: [String]
    
    @State private var displayedLines: [RollingText] = []
    @State private var nextIndex = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(displayedLines) { line in
                RollingLineView(line: line)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
            }
        }
        .onAppear {
            startScrolling()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startScrolling() {
        guard !texts.isEmpty else { return }
        
        // Populate initial lines (up to 3)
        if texts.count >= 3 {
            displayedLines = [
                RollingText(id: UUID(), text: texts[0], shouldType: false),
                RollingText(id: UUID(), text: texts[1], shouldType: false),
                RollingText(id: UUID(), text: texts[2], shouldType: false)
            ]
            nextIndex = 3
        } else {
            displayedLines = texts.map { RollingText(id: UUID(), text: $0, shouldType: false) }
            nextIndex = 0
        }
        
        // Only schedule cycling if there are more than 3 texts to cycle
        guard texts.count > 3 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            cycleLines()
        }
    }
    
    private func cycleLines() {
        let nextText = texts[nextIndex]
        nextIndex = (nextIndex + 1) % texts.count
        
        withAnimation(.easeInOut(duration: 0.8)) {
            // Remove the top line (which triggers the .top transition)
            if !displayedLines.isEmpty {
                displayedLines.removeFirst()
            }
            
            // Append the new line at the bottom (which triggers the .bottom transition)
            let newLine = RollingText(id: UUID(), text: nextText, shouldType: true)
            displayedLines.append(newLine)
        }
    }
}

struct RollingLineView: View {
    let line: RollingText
    
    var body: some View {
        if line.shouldType {
            TypingTextView(fullText: line.text)
        } else {
            Text(line.text)
                .font(.system(.body, design: .rounded).weight(.light))
                .foregroundColor(Color.primary.opacity(0.85))
        }
    }
}

struct TypingTextView: View {
    let fullText: String
    
    @State private var displayedText = ""
    @State private var currentIndex = 0
    
    var body: some View {
        Text(displayedText)
            .font(.system(.body, design: .rounded).weight(.light))
            .foregroundColor(Color.primary.opacity(0.85))
            .onAppear {
                startTyping()
            }
    }
    
    private func startTyping() {
        displayedText = ""
        currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
