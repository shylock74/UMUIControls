//
//  UMUILayoutConfig.swift
//  UMUIControls
//
//  Layout metrics (label widths, window sizes, ...) read at run time from a
//  UM User Interface Configurator project, the ".umuic" JSON file bundled with
//  the app. While the Configurator app edits the project it broadcasts every
//  change, and an observing UMUILayoutConfig republishes, so a Debug build
//  can be retuned live without rebuilding.
//
//  A dependency-free port of UMSwiftUI's UMConfig: same file format, same
//  broadcast, same group / key lookup.
//

import SwiftUI
import Combine
#if os(macOS)
import AppKit
#endif

/// Values of a UM User Interface Configurator project, looked up by group and key.
///
/// Apps declare their metrics as computed properties in an extension, reading
/// the project in Debug and baking the value in Release:
///
/// ```swift
/// extension UMUILayoutConfig {
///     var settingsWindow_labelW: Double {
///     #if DEBUG
///         double("settingsWindow", "labelW")
///     #else
///         132.0
///     #endif
///     }
/// }
///
/// struct SettingsRow: View {
///     @ObservedObject private var layout = UMUILayoutConfig.shared
///     var body: some View {
///         UMUITextField(label: "Name", value: $name, labelWidth: layout.settingsWindow_labelW)
///     }
/// }
/// ```
@available(macOS 10.15, iOS 13.0, *)
public final class UMUILayoutConfig: ObservableObject {

    /// The project file name used when none is given.
    public static let defaultFileName = "UMConfigurator"

    /// The project file extension.
    public static let fileExtension = "umuic"

    /// The app's configuration, read from `UMConfigurator.umuic` in the main bundle.
    public static let shared = UMUILayoutConfig()

    private var project: UMUILayoutProject?
    private let appBundleId: String

    /// Loads `configFileName.umuic` from `bundle` and, when `observesConfigurator`
    /// is on, listens for the Configurator app's live updates.
    public init(
        configFileName: String = UMUILayoutConfig.defaultFileName,
        bundle: Bundle = .main,
        observesConfigurator: Bool = true
    ) {
        appBundleId = bundle.bundleIdentifier?.lowercased() ?? ""
        if let url = bundle.url(forResource: configFileName, withExtension: Self.fileExtension),
           let data = try? Data(contentsOf: url) {
            project = try? JSONDecoder().decode(UMUILayoutProject.self, from: data)
        }
        if observesConfigurator {
            observe()
        }
    }

    deinit {
        #if os(macOS)
        DistributedNotificationCenter.default().removeObserver(self)
        #endif
    }

    // MARK: - Lookup

    /// The `Double` stored under `group` / `key`, else `def`, else the project default (64).
    public func double(_ group: String, _ key: String, def: Double? = nil) -> Double {
        project?.item(key, in: group)?.doubleValue ?? def ?? project?.defaultDoubleValue ?? 64
    }

    /// The `Double` stored under `group` / `key`, never below `min`.
    public func double(_ group: String, _ key: String, min: Double) -> Double {
        max(project?.item(key, in: group)?.doubleValue ?? min, min)
    }

    /// The `Int` stored under `group` / `key`, else `def`, else the project default (0).
    public func int(_ group: String, _ key: String, def: Int? = nil) -> Int {
        project?.item(key, in: group)?.intValue ?? def ?? project?.defaultIntValue ?? 0
    }

    /// The `Int` stored under `group` / `key`, never below `min`.
    public func int(_ group: String, _ key: String, min: Int) -> Int {
        max(project?.item(key, in: group)?.intValue ?? min, min)
    }

    /// The `String` stored under `group` / `key`, else `def`.
    public func string(_ group: String, _ key: String, def: String = "") -> String {
        project?.item(key, in: group)?.stringValue ?? def
    }

    /// The `Bool` stored under `group` / `key`, else `def`, else the project default (true).
    public func bool(_ group: String, _ key: String, def: Bool? = nil) -> Bool {
        project?.item(key, in: group)?.boolValue ?? def ?? project?.defaultBoolValue ?? true
    }

    /// The point stored under `group` / `key`, else `def`.
    public func pointSize(_ group: String, _ key: String, def: CGPoint = .zero) -> CGPoint {
        guard let point = project?.item(key, in: group)?.pointValue else {
            return def
        }
        return CGPoint(x: point.x, y: point.y)
    }

    // MARK: - Live updates

    /// The name the Configurator broadcasts under: the bundle id without dots.
    private var notificationName: String {
        "ulti.media.umuic.broadcast.\(appBundleId.replacingOccurrences(of: ".", with: ""))"
    }

    private func observe() {
        #if os(macOS)
        DistributedNotificationCenter.default().addObserver(self,
                                                            selector: #selector(handleBroadcast(_:)),
                                                            name: NSNotification.Name(notificationName),
                                                            object: nil)
        #endif
    }

    @objc private func handleBroadcast(_ notification: Notification) {
        guard let json = notification.userInfo?["string"] as? String,
              let data = json.data(using: .utf8),
              let updated = try? JSONDecoder().decode(UMUILayoutProject.self, from: data) else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.project = updated
            self?.objectWillChange.send()
        }
    }
}

// MARK: - Project file

/// The part of a ".umuic" project a running app needs. Decoding is lenient, like
/// the Configurator's own: a missing field takes its default.
@available(macOS 10.15, iOS 13.0, *)
struct UMUILayoutProject: Decodable {

    struct Point: Decodable {
        var x: CGFloat = 0
        var y: CGFloat = 0
    }

    struct Item: Decodable {
        var key = ""
        var intValue = 0
        var doubleValue: Double = 0
        var stringValue = ""
        var boolValue = true
        var pointValue = Point()
        var shouldBeDeleted = false

        private enum CodingKeys: String, CodingKey {
            case key, intValue, doubleValue, stringValue, boolValue, pointValue, shouldBeDeleted
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            key = (try? container.decodeIfPresent(String.self, forKey: .key)) ?? ""
            intValue = (try? container.decodeIfPresent(Int.self, forKey: .intValue)) ?? 0
            doubleValue = (try? container.decodeIfPresent(Double.self, forKey: .doubleValue)) ?? 0
            stringValue = (try? container.decodeIfPresent(String.self, forKey: .stringValue)) ?? ""
            boolValue = (try? container.decodeIfPresent(Bool.self, forKey: .boolValue)) ?? true
            pointValue = (try? container.decodeIfPresent(Point.self, forKey: .pointValue)) ?? Point()
            shouldBeDeleted = (try? container.decodeIfPresent(Bool.self, forKey: .shouldBeDeleted)) ?? false
        }

        /// The key as written in code: `UMUILayoutProject.codeToken(key)`.
        var codeKey: String {
            UMUILayoutProject.codeToken(key)
        }
    }

    struct Group: Decodable {
        var name = ""
        var itemList: [Item] = []

        private enum CodingKeys: String, CodingKey {
            case name, itemList
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = (try? container.decodeIfPresent(String.self, forKey: .name)) ?? ""
            itemList = ((try? container.decodeIfPresent([Item].self, forKey: .itemList)) ?? [])
                .filter { !$0.shouldBeDeleted }
        }

        /// The group name as written in code.
        var codeName: String {
            UMUILayoutProject.codeToken(name)
        }
    }

    var groupList: [Group] = []
    var defaultDoubleValue: Double = 64
    var defaultIntValue = 0
    var defaultBoolValue = true

    private enum CodingKeys: String, CodingKey {
        case groupList, defaultDoubleValue, defaultIntValue, defaultBoolValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupList = (try? container.decodeIfPresent([Group].self, forKey: .groupList)) ?? []
        defaultDoubleValue = (try? container.decodeIfPresent(Double.self, forKey: .defaultDoubleValue)) ?? 64
        defaultIntValue = (try? container.decodeIfPresent(Int.self, forKey: .defaultIntValue)) ?? 0
        defaultBoolValue = (try? container.decodeIfPresent(Bool.self, forKey: .defaultBoolValue)) ?? true
    }

    /// The item whose code key is `key` in the group whose code name is `group`.
    func item(_ key: String, in group: String) -> Item? {
        groupList.first { $0.codeName == group }?.itemList.first { $0.codeKey == key }
    }

    /// The Configurator's identifier rule: leading digits dropped, first letter
    /// lowercased, anything but letters, digits and spaces removed, and each
    /// space dropped with the letter after it capitalized ("Settings Window" → "settingsWindow").
    static func codeToken(_ text: String) -> String {
        var characters = Substring(text)
        while let first = characters.first, first.isASCII, first.isNumber {
            characters = characters.dropFirst()
        }
        guard let first = characters.first else {
            return ""
        }
        let allowed = Set("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM0123456789 ")
        var result = first.lowercased()
        var capitalizeNext = false
        for character in characters.dropFirst() where allowed.contains(character) {
            if character == " " {
                capitalizeNext = true
            } else {
                result += capitalizeNext ? character.uppercased() : String(character)
                capitalizeNext = false
            }
        }
        return result
    }
}
