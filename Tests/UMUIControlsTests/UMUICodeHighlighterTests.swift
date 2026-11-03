import Foundation
import Testing
@testable import UMUIControls

@Suite struct UMUICodeHighlighterTests {

    private func texts(_ kind: UMUICodeTokenKind, in text: String, _ language: UMUICodeLanguage) -> [String] {
        UMUICodeHighlighter.tokens(in: text, language: language)
            .filter { $0.kind == kind }
            .map { (text as NSString).substring(with: $0.range) }
    }

    @Test func yamlKeysIncludeListItemKeys() {
        let yaml = """
        context_name: "Demo"
        entities:
          - canonical: "Exmachina"
            sounds_like:
              - "ex macchina"
        """
        #expect(texts(.key, in: yaml, .yaml) == ["context_name", "entities", "canonical", "sounds_like"])
    }

    @Test func yamlStringsAndComments() {
        let yaml = """
        name: "Demo" # a note
          - 'single'
        """
        #expect(texts(.string, in: yaml, .yaml) == ["\"Demo\"", "'single'"])
        #expect(texts(.comment, in: yaml, .yaml) == ["# a note"])
    }

    @Test func jsonKeysAreNotPlainStrings() {
        let json = #"{"name": "Demo", "n": 3, "ok": true}"#
        #expect(texts(.key, in: json, .json) == ["\"name\"", "\"n\"", "\"ok\""])
        #expect(texts(.number, in: json, .json) == ["3"])
        #expect(texts(.keyword, in: json, .json) == ["true"])
    }

    @Test func markdownHeadingsAndBold() {
        let md = """
        # Title
        * **Term**: description
        """
        #expect(texts(.heading, in: md, .markdown) == ["# Title"])
        #expect(texts(.emphasis, in: md, .markdown) == ["**Term**"])
    }

    @Test func plainTextHasNoTokens() {
        #expect(UMUICodeHighlighter.tokens(in: "key: value", language: .plainText).isEmpty)
    }
}
