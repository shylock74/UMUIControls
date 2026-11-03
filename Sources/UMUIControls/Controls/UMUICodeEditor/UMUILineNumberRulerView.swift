//
//  UMUILineNumberRulerView.swift
//  UMUIControls
//
//  Vertical ruler that draws line numbers next to a TextKit 1 NSTextView.
//  Only logical lines are numbered: a wrapped line shows its number once.
//

import AppKit

final class UMUILineNumberRulerView: NSRulerView {

    private weak var textView: NSTextView?

    private var font: NSFont {
        NSFont.monospacedDigitSystemFont(ofSize: max(9, (textView?.font?.pointSize ?? 12) - 2), weight: .regular)
    }

    init(textView: NSTextView, scrollView: NSScrollView) {
        self.textView = textView
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        clientView = textView
        ruleThickness = 34
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// Widens the ruler when the line count gains a digit.
    func updateThickness() {
        guard let textView else { return }
        let lines = (textView.string as NSString).components(separatedBy: "\n").count
        let digits = max(2, String(lines).count)
        let width = CGFloat(digits) * (font.maximumAdvancement.width) + 14
        if abs(ruleThickness - width) > 0.5 {
            ruleThickness = width
        }
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        NSColor.controlBackgroundColor.setFill()
        bounds.fill()
        NSColor.separatorColor.setFill()
        NSRect(x: bounds.maxX - 1, y: bounds.minY, width: 1, height: bounds.height).fill()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.tertiaryLabelColor,
        ]

        let string = textView.string as NSString
        let visibleRect = textView.visibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        // Line number of the first visible character.
        var lineNumber = 1
        if charRange.location > 0 {
            let prefix = string.substring(to: charRange.location)
            lineNumber += prefix.reduce(0) { $1 == "\n" ? $0 + 1 : $0 }
        }

        func draw(_ number: Int, atTextY y: CGFloat, height: CGFloat) {
            let label = "\(number)" as NSString
            let size = label.size(withAttributes: attributes)
            let point = convert(NSPoint(x: 0, y: y + textView.textContainerOrigin.y), from: textView)
            let drawPoint = NSPoint(x: ruleThickness - size.width - 6,
                                    y: point.y + (height - size.height) / 2)
            label.draw(at: drawPoint, withAttributes: attributes)
        }

        var index = charRange.location
        while index < NSMaxRange(charRange) {
            let lineRange = string.lineRange(for: NSRange(location: index, length: 0))
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: lineRange.location)
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
            draw(lineNumber, atTextY: lineRect.minY, height: lineRect.height)
            lineNumber += 1
            index = NSMaxRange(lineRange)
        }

        // The empty last line after a trailing newline (or an empty document).
        let extra = layoutManager.extraLineFragmentRect
        if !extra.isEmpty, extra.intersects(visibleRect) || string.length == 0 {
            draw(lineNumber, atTextY: extra.minY, height: extra.height)
        }
    }
}
