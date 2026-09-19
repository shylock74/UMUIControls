//
//  UMUIEmptyStateView.swift
//  UMUIControls
//
//  A centered placeholder for empty lists, unselected panes and locked stages:
//  a large symbol, a title, an explanation and an optional call to action.
//

import SwiftUI

/// A centered empty-state placeholder with an optional action button.
///
/// Usage:
/// ```swift
/// UMUIEmptyStateView(systemImage: "calendar.badge.plus",
///                    title: "No Event Selected",
///                    message: "Create an event to start a brief.",
///                    actionTitle: "Add New Event") {
///     addEvent()
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIEmptyStateView: View {
    public let systemImage: String
    public let title: String
    public let message: String?
    public let actionTitle: String?
    public let action: (() -> Void)?

    public init(
        systemImage: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .light))
                .foregroundColor(.secondary.opacity(0.7))

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            if let message = message {
                Text(message)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }

            if let actionTitle = actionTitle, let action = action {
                UMUICapsuleButton(actionTitle, style: .accent, size: .normal, action: action)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        UMUIEmptyStateView(systemImage: "calendar.badge.plus",
                           title: "No Event Selected",
                           message: "Create an event to start a brief.",
                           actionTitle: "Add New Event") {}
            .frame(width: 480, height: 320)
    }
}
#endif
