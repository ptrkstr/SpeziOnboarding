//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The ``SequentialOnboardingView`` provides a view to display information that is displayed step by step.
///
/// The ``OnboardingView`` provides an alternative to provide  information that is displayed all at once.
///
/// The following example demonstrates the usage of the ``SequentialOnboardingView``:
/// ```swift
/// SequentialOnboardingView(
///     title: "Title",
///     subtitle: "Subtitle",
///     content: [
///         .init(
///             title: "A thing to know",
///             description: "This is a first thing that you should know, read carefully!")
///         ,
///         .init(
///             title: "Second thing to know",
///             description: "This is a second thing that you should know, read carefully!"
///         ),
///         .init(
///             title: "Third thing to know",
///             description: "This is a third thing that you should know, read carefully!"
///         )
///     ],
///     actionText: "Continue"
/// ) {
///     // Action that should be performed on pressing the "Continue" button ...
/// }
/// ```
public struct SequentialOnboardingView: View {
    /// A ``Content`` defines the way that information is displayed in an ``SequentialOnboardingView``.
    public struct Content {
        /// The title of the area in the ``SequentialOnboardingView``.
        public let title: String?
        /// The description of the area in the ``SequentialOnboardingView``.
        public let description: String
        
        
        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - title: The localized title of the area in the ``SequentialOnboardingView``.
        ///   - description: The localized description of the area in the ``SequentialOnboardingView``.
        public init( // swiftlint:disable:this function_default_parameter_at_end
            title: LocalizedStringResource? = nil,
            description: LocalizedStringResource
        ) {
            if let title {
                self.init(title: title.localizedString(), description: description.localizedString())
            } else {
                self.init(description: description.localizedString())
            }
        }
        
        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - title: The title of the area in the ``SequentialOnboardingView`` without localization.
        ///   - description: The description of the area in the ``SequentialOnboardingView`` without localization.
        @_disfavoredOverload
        public init<Title: StringProtocol, Description: StringProtocol>(
            title: Title,
            description: Description
        ) {
            self.title = String(title)
            self.description = String(description)
        }

        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - description: The description of the area in the ``SequentialOnboardingView`` without localization.
        @_disfavoredOverload
        public init<Description: StringProtocol>(
            description: Description
        ) {
            self.title = nil
            self.description = String(description)
        }
    }
    
    
    private let titleView: AnyView
    private let content: [Content]
    @State private var currentContentIndex: Int = 0
    private let actionText: String
    private let action: () async throws -> Void
    
    
    public var body: some View {
        ScrollViewReader { proxy in
            OnboardingView(
                titleView: {
                    titleView
                },
                contentView: {
                    ForEach(0..<content.count, id: \.self) { index in
                        if index <= currentContentIndex {
                            stepView(index: index)
                                .id(index)
                        }
                    }
                },
                actionView: {
                    OnboardingActionsView(
                        actionButtonTitle
                    ) {
                        if currentContentIndex < content.count - 1 {
                            currentContentIndex += 1
                            withAnimation {
                                proxy.scrollTo(currentContentIndex - 1, anchor: .top)
                            }
                        } else {
                            try await action()
                        }
                    }
                }
            )
        }
    }
    
    private var actionButtonTitle: String {
        if currentContentIndex < content.count - 1 {
            return String(localized: "SEQUENTIAL_ONBOARDING_NEXT", bundle: .module)
        } else {
            return actionText
        }
    }
    
    
    /// Creates the default style of the ``SequentialOnboardingView`` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The localized title of the ``SequentialOnboardingView``.
    ///   - subtitle: The localized subtitle of the ``SequentialOnboardingView``.
    ///   - content: The areas of the ``SequentialOnboardingView`` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The localized text that should appear on the ``SequentialOnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        content: [Content],
        actionText: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) {
        self.init(
            titleView: OnboardingTitleView(title: title, subtitle: subtitle),
            content: content,
            actionText: actionText.localizedString(),
            action: action
        )
    }
    
    /// Creates the default style of the ``SequentialOnboardingView`` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title of the ``SequentialOnboardingView`` without localization.
    ///   - content: The areas of the ``SequentialOnboardingView`` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The text that should appear on the ``SequentialOnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<Title: StringProtocol, ActionText: StringProtocol>(
        title: Title,
        content: [Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) {
        self.init(
            titleView: OnboardingTitleView(title: title),
            content: content,
            actionText: String(actionText),
            action: action
        )
    }
    
    /// Creates the default style of the ``SequentialOnboardingView`` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title of the ``SequentialOnboardingView`` without localization.
    ///   - subtitle: The subtitle of the ``SequentialOnboardingView`` without localization.
    ///   - content: The areas of the ``SequentialOnboardingView`` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The text that should appear on the ``SequentialOnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<Title: StringProtocol, Subtitle: StringProtocol, ActionText: StringProtocol>(
        title: Title,
        subtitle: Subtitle?,
        content: [Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) {
        self.init(
            titleView: OnboardingTitleView(title: title, subtitle: subtitle),
            content: content,
            actionText: String(actionText),
            action: action
        )
    }
    
    
    /// Creates a customized ``SequentialOnboardingView`` allowing a complete customization of the  ``SequentialOnboardingView``'s title view.
    ///
    /// - Parameters:
    ///   - titleView: The title view displayed at the top.
    ///   - content: The areas of the ``SequentialOnboardingView`` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The text that should appear on the ``SequentialOnboardingView``'s primary button without localization.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<TitleView: View, ActionText: StringProtocol>(
        titleView: TitleView,
        content: [Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) {
        self.titleView = AnyView(titleView)
        self.content = content
        self.actionText = String(actionText)
        self.action = action
    }
    
    /// Creates a customized ``SequentialOnboardingView`` allowing a complete customization of the  ``SequentialOnboardingView``'s title view.
    ///
    /// - Parameters:
    ///   - titleView: The title view displayed at the top.
    ///   - content: The areas of the ``SequentialOnboardingView`` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The localized text that should appear on the ``SequentialOnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init<TitleView: View>(
        titleView: TitleView,
        content: [Content],
        actionText: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) {
        self.titleView = AnyView(titleView)
        self.content = content
        self.actionText = actionText.localizedString()
        self.action = action
    }
    
    
    private func stepView(index: Int) -> some View {
        let content = content[index]
        return HStack {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(index + 1)")
                    .bold()
                    .foregroundColor(.white)
                    .padding(12)
                    .background {
                        Circle()
                            .fill(Color.accentColor)
                    }
                VStack(alignment: .leading, spacing: 8) {
                    if let title = content.title {
                        Text(title)
                            .bold()
                    }
                    Text(content.description)
                }
                Spacer()
            }
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGroupedBackground))
                }
        }
    }
}


#if DEBUG
struct SequentialOnboardingView_Previews: PreviewProvider {
    static var mock: [SequentialOnboardingView.Content] {
        [
            .init(title: "A thing to know", description: "This is a first thing that you should know, read carfully!"),
            .init(title: "Second thing to know", description: "This is a second thing that you should know, read carfully!"),
            .init(title: "Third thing to know", description: "This is a third thing that you should know, read carfully!")
        ]
    }
    
    static var previews: some View {
        SequentialOnboardingView(
            title: "Title",
            subtitle: "Subtitle",
            content: mock,
            actionText: "Continue"
        ) {
            print("Done!")
        }
    }
}
#endif
