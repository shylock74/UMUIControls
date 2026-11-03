//
//  UMUICodeHighlighter.swift
//  UMUIControls
//
//  Regex-based, line-oriented syntax highlighting for the small structured
//  documents UMUICodeEditor is meant for: YAML, JSON, Markdown, plain text.
//  The tokenizer is pure (string in, ranges out) so it can be unit-tested;
//  colouring is a separate step done on the text storage.
//

import AppKit

/// The syntax `UMUICodeEditor` highlights.
public enum UMUICodeLanguage: String, Sendable, CaseIterable, Equatable {
    case plainText
    case yaml
    case json
    case markdown
}

/// What a highlighted range is.
public enum UMUICodeTokenKind: Sendable, Equatable {
    case key
    case string
    case number
    case keyword
    case comment
    case punctuation
    case heading
    case emphasis
    case code
}

/// One highlighted range.
public struct UMUICodeToken: Sendable, Equatable {
    public let range: NSRange
    public let kind: UMUICodeTokenKind

    public init(range: NSRange, kind: UMUICodeTokenKind) {
        self.range = range
        self.kind = kind
    }
}

/// Turns text into highlight tokens. Later rules win over earlier ones when
/// ranges overlap, because they are applied in order.
public enum UMUICodeHighlighter {

    private struct Rule {
        let regex: NSRegularExpression
        let kind: UMUICodeTokenKind
        /// Capture group to colour; 0 is the whole match.
        let group: Int
    }

    private static func rule(_ pattern: String, _ kind: UMUICodeTokenKind, group: Int = 0) -> Rule {
        // The patterns are literals: a failure is a programming error.
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        return Rule(regex: regex, kind: kind, group: group)
    }

    private static let yamlRules: [Rule] = [
        rule(#"^\s*(-)\s"#, .punctuation, group: 1),
        rule(#"^---\s*$"#, .punctuation),
        rule(#"^\s*(?:-\s+)?([^\s#:"'][^:#\n]*?|"[^"\n]*"|'[^'\n]*')\s*:(?=\s|$)"#, .key, group: 1),
        rule(#":\s+(-?\d+(?:\.\d+)?)\s*$"#, .number, group: 1),
        rule(#":\s+(true|false|null|yes|no|~)\s*$"#, .keyword, group: 1),
        rule(#"(?<=:\s|-\s|\[|,\s)"[^"\n]*""#, .string),
        rule(#"(?<=:\s|-\s|\[|,\s)'[^'\n]*'"#, .string),
        rule(#"(?:^|\s)(#.*)$"#, .comment, group: 1),
    ]

    private static let jsonRules: [Rule] = [
        rule(#"[{}\[\],:]"#, .punctuation),
        rule(#"-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b"#, .number),
        rule(#"\b(true|false|null)\b"#, .keyword),
        rule(#""(?:[^"\\\n]|\\.)*""#, .string),
        rule(#"("(?:[^"\\\n]|\\.)*")\s*:"#, .key, group: 1),
    ]

    private static let markdownRules: [Rule] = [
        rule(#"^\s*([-*+]|\d+\.)\s"#, .punctuation, group: 1),
        rule(#"^\s*\|.*\|\s*$"#, .punctuation),
        rule(#"\*\*[^*\n]+\*\*|__[^_\n]+__"#, .emphasis),
        rule(#"`[^`\n]+`"#, .code),
        rule(#"^```.*$"#, .code),
        rule(#"^#{1,6}\s.*$"#, .heading),
        rule(#"^>.*$"#, .comment),
    ]

    private static func rules(for language: UMUICodeLanguage) -> [Rule] {
        switch language {
        case .plainText: return []
        case .yaml: return yamlRules
        case .json: return jsonRules
        case .markdown: return markdownRules
        }
    }

    /// Tokens for `text` inside `range` (the whole string when `nil`).
    public static func tokens(in text: String,
                              language: UMUICodeLanguage,
                              range: NSRange? = nil) -> [UMUICodeToken] {
        let nsText = text as NSString
        let searchRange = range ?? NSRange(location: 0, length: nsText.length)
        var result: [UMUICodeToken] = []
        for rule in rules(for: language) {
            rule.regex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
                guard let match else { return }
                let r = match.range(at: rule.group)
                guard r.location != NSNotFound, r.length > 0 else { return }
                result.append(UMUICodeToken(range: r, kind: rule.kind))
            }
        }
        return result
    }

    /// The colour used for each token kind. System colours, so they follow
    /// light and dark appearance.
    public static func color(for kind: UMUICodeTokenKind) -> NSColor {
        switch kind {
        case .key: return .systemPurple
        case .string: return .systemRed
        case .number: return .systemBlue
        case .keyword: return .systemPink
        case .comment: return .secondaryLabelColor
        case .punctuation: return .systemOrange
        case .heading: return .systemBlue
        case .emphasis: return .labelColor
        case .code: return .systemBrown
        }
    }

    /// Recolours `range` (expanded to whole lines) of `storage`.
    @MainActor
    static func apply(to storage: NSTextStorage,
                      language: UMUICodeLanguage,
                      font: NSFont,
                      range: NSRange? = nil) {
        let nsText = storage.string as NSString
        let full = NSRange(location: 0, length: nsText.length)
        let target = range.map { nsText.lineRange(for: NSIntersectionRange($0, full)) } ?? full
        guard target.length > 0 else { return }

        let boldFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)

        storage.beginEditing()
        storage.setAttributes([.font: font, .foregroundColor: NSColor.textColor], range: target)
        for token in tokens(in: storage.string, language: language, range: target) {
            storage.addAttribute(.foregroundColor, value: color(for: token.kind), range: token.range)
            if token.kind == .heading || token.kind == .emphasis || token.kind == .key {
                storage.addAttribute(.font, value: boldFont, range: token.range)
            }
        }
        storage.endEditing()
    }
}
