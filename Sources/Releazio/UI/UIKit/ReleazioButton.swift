//
//  ReleazioButton.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

#if canImport(UIKit)
import UIKit

/// Custom button component for Releazio UI elements
public class ReleazioButton: UIButton {

    // MARK: - Properties

    /// Button style
    public let style: ReleazioButtonStyle

    /// Theme configuration
    public let theme: ReleazioButtonTheme

    /// Loading state
    public private(set) var isLoading = false

    // MARK: - UI Components

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.font
        label.textColor = theme.textColor
        label.textAlignment = .center
        return label
    }()

    private lazy var originalTitle: String = ""

    // MARK: - Initialization

    /// Initialize Releazio button
    /// - Parameters:
    ///   - style: Button style
    ///   - theme: Button theme
    ///   - frame: Button frame
    public init(
        style: ReleazioButtonStyle = .primary,
        theme: ReleazioButtonTheme = .default,
        frame: CGRect = .zero
    ) {
        self.style = style
        self.theme = theme
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    private func setupButton() {
        configureAppearance()
        setupConstraints()
        setupActions()
    }

    private func configureAppearance() {
        // Apply style-specific appearance
        switch style {
        case .primary:
            backgroundColor = theme.primaryBackgroundColor
            setTitleColor(theme.primaryTextColor, for: .normal)
            layer.borderColor = theme.primaryBorderColor.cgColor
            layer.borderWidth = theme.borderWidth
        case .secondary:
            backgroundColor = theme.secondaryBackgroundColor
            setTitleColor(theme.secondaryTextColor, for: .normal)
            layer.borderColor = theme.secondaryBorderColor.cgColor
            layer.borderWidth = theme.borderWidth
        case .outline:
            backgroundColor = .clear
            setTitleColor(theme.outlineTextColor, for: .normal)
            layer.borderColor = theme.outlineBorderColor.cgColor
            layer.borderWidth = theme.borderWidth
        case .destructive:
            backgroundColor = theme.destructiveBackgroundColor
            setTitleColor(theme.destructiveTextColor, for: .normal)
            layer.borderColor = theme.destructiveBorderColor.cgColor
            layer.borderWidth = theme.borderWidth
        }

        // Common appearance
        titleLabel?.font = theme.font
        layer.cornerRadius = theme.cornerRadius
        clipsToBounds = true

        // Add shadow if enabled
        if theme.shadowEnabled {
            layer.shadowColor = theme.shadowColor.cgColor
            layer.shadowRadius = theme.shadowRadius
            layer.shadowOpacity = theme.shadowOpacity
            layer.shadowOffset = theme.shadowOffset
        }

        // Content insets
        contentEdgeInsets = UIEdgeInsets(
            top: theme.verticalPadding,
            left: theme.horizontalPadding,
            bottom: theme.verticalPadding,
            right: theme.horizontalPadding
        )
    }

    private func setupConstraints() {
        // Add activity indicator and loading label
        addSubview(activityIndicator)
        addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Loading label constraints
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])

        // Initially hide loading elements
        activityIndicator.isHidden = true
        loadingLabel.isHidden = true
    }

    private func setupActions() {
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Public Methods

    /// Set loading state
    /// - Parameters:
    ///   - loading: Whether button is loading
    ///   - loadingText: Text to show during loading
    public func setLoading(_ loading: Bool, loadingText: String? = nil) {
        isLoading = loading

        if loading {
            // Store original title
            originalTitle = title(for: .normal) ?? ""

            // Show loading state
            setTitle("", for: .normal)
            loadingLabel.text = loadingText ?? "Loading..."
            loadingLabel.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()

            // Disable button
            isEnabled = false
            alpha = theme.disabledAlpha
        } else {
            // Restore normal state
            setTitle(originalTitle, for: .normal)
            loadingLabel.isHidden = true
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()

            // Enable button
            isEnabled = true
            alpha = 1.0
        }
    }

    /// Animate button with spring effect
    public func animateSpring() {
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.transform = .identity
        }
    }

    /// Shake animation for error states
    public func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }

    // MARK: - Actions

    @objc private func buttonTapped() {
        animateSpring()

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = self.theme.pressedAlpha
        }
    }

    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = self.isEnabled ? 1.0 : self.theme.disabledAlpha
        }
    }
}

// MARK: - Button Style

public enum ReleazioButtonStyle {
    case primary
    case secondary
    case outline
    case destructive
}

// MARK: - Button Theme

public struct ReleazioButtonTheme {
    public let font: UIFont
    public let cornerRadius: CGFloat
    public let borderWidth: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let shadowEnabled: Bool
    public let shadowColor: UIColor
    public let shadowRadius: CGFloat
    public let shadowOpacity: Float
    public let shadowOffset: CGSize
    public let disabledAlpha: CGFloat
    public let pressedAlpha: CGFloat
    public let textColor: UIColor

    // Colors
    public let primaryBackgroundColor: UIColor
    public let primaryTextColor: UIColor
    public let primaryBorderColor: UIColor

    public let secondaryBackgroundColor: UIColor
    public let secondaryTextColor: UIColor
    public let secondaryBorderColor: UIColor

    public let outlineBackgroundColor: UIColor
    public let outlineTextColor: UIColor
    public let outlineBorderColor: UIColor

    public let destructiveBackgroundColor: UIColor
    public let destructiveTextColor: UIColor
    public let destructiveBorderColor: UIColor

    public init(
        font: UIFont = UIFont.boldSystemFont(ofSize: 16),
        cornerRadius: CGFloat = 12,
        borderWidth: CGFloat = 1,
        horizontalPadding: CGFloat = 24,
        verticalPadding: CGFloat = 12,
        shadowEnabled: Bool = true,
        shadowColor: UIColor = .black,
        shadowRadius: CGFloat = 4,
        shadowOpacity: Float = 0.15,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        disabledAlpha: CGFloat = 0.6,
        pressedAlpha: CGFloat = 0.8,
        textColor: UIColor = .label,
        primaryBackgroundColor: UIColor = .systemBlue,
        primaryTextColor: UIColor = .white,
        primaryBorderColor: UIColor = .clear,
        secondaryBackgroundColor: UIColor = .secondarySystemFill,
        secondaryTextColor: UIColor = .label,
        secondaryBorderColor: UIColor = .clear,
        outlineBackgroundColor: UIColor = .clear,
        outlineTextColor: UIColor = .systemBlue,
        outlineBorderColor: UIColor = .systemBlue,
        destructiveBackgroundColor: UIColor = .systemRed,
        destructiveTextColor: UIColor = .white,
        destructiveBorderColor: UIColor = .clear
    ) {
        self.font = font
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.shadowEnabled = shadowEnabled
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
        self.disabledAlpha = disabledAlpha
        self.pressedAlpha = pressedAlpha
        self.textColor = textColor

        self.primaryBackgroundColor = primaryBackgroundColor
        self.primaryTextColor = primaryTextColor
        self.primaryBorderColor = primaryBorderColor

        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.secondaryTextColor = secondaryTextColor
        self.secondaryBorderColor = secondaryBorderColor

        self.outlineBackgroundColor = outlineBackgroundColor
        self.outlineTextColor = outlineTextColor
        self.outlineBorderColor = outlineBorderColor

        self.destructiveBackgroundColor = destructiveBackgroundColor
        self.destructiveTextColor = destructiveTextColor
        self.destructiveBorderColor = destructiveBorderColor
    }

    /// Default theme
    public static let `default` = ReleazioButtonTheme()

    /// Compact theme for smaller buttons
    public static let compact = ReleazioButtonTheme(
        font: UIFont.boldSystemFont(ofSize: 14),
        cornerRadius: 8,
        horizontalPadding: 16,
        verticalPadding: 8,
        shadowRadius: 2,
        shadowOffset: CGSize(width: 0, height: 1)
    )

    /// Large theme for prominent buttons
    public static let large = ReleazioButtonTheme(
        font: UIFont.boldSystemFont(ofSize: 18),
        cornerRadius: 16,
        horizontalPadding: 32,
        verticalPadding: 16,
        shadowRadius: 6,
        shadowOffset: CGSize(width: 0, height: 3)
    )

    /// Minimal theme without shadows
    public static let minimal = ReleazioButtonTheme(
        font: UIFont.systemFont(ofSize: 16, weight: .medium),
        cornerRadius: 6,
        borderWidth: 0,
        horizontalPadding: 20,
        verticalPadding: 10,
        shadowEnabled: false,
        shadowColor: .clear,
        shadowRadius: 0,
        shadowOpacity: 0,
        shadowOffset: .zero
    )
}

// MARK: - Convenience Factory Methods

extension ReleazioButton {

    /// Create primary action button
    /// - Parameters:
    ///   - title: Button title
    ///   - theme: Theme configuration
    ///   - action: Button action
    /// - Returns: Configured button
    public static func primaryButton(
        title: String,
        theme: ReleazioButtonTheme = .default,
        action: @escaping () -> Void
    ) -> ReleazioButton {
        let button = ReleazioButton(style: .primary, theme: theme)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    /// Create secondary button
    /// - Parameters:
    ///   - title: Button title
    ///   - theme: Theme configuration
    ///   - action: Button action
    /// - Returns: Configured button
    public static func secondaryButton(
        title: String,
        theme: ReleazioButtonTheme = .default,
        action: @escaping () -> Void
    ) -> ReleazioButton {
        let button = ReleazioButton(style: .secondary, theme: theme)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    /// Create outline button
    /// - Parameters:
    ///   - title: Button title
    ///   - theme: Theme configuration
    ///   - action: Button action
    /// - Returns: Configured button
    public static func outlineButton(
        title: String,
        theme: ReleazioButtonTheme = .default,
        action: @escaping () -> Void
    ) -> ReleazioButton {
        let button = ReleazioButton(style: .outline, theme: theme)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    /// Create destructive button
    /// - Parameters:
    ///   - title: Button title
    ///   - theme: Theme configuration
    ///   - action: Button action
    /// - Returns: Configured button
    public static func destructiveButton(
        title: String,
        theme: ReleazioButtonTheme = .default,
        action: @escaping () -> Void
    ) -> ReleazioButton {
        let button = ReleazioButton(style: .destructive, theme: theme)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
}

// MARK: - Preview Helper

#if DEBUG
import SwiftUI

struct ReleazioButtonUIViewRepresentable: UIViewRepresentable {
    let title: String
    let style: ReleazioButtonStyle
    let theme: ReleazioButtonTheme

    func makeUIView(context: Context) -> ReleazioButton {
        let button = ReleazioButton(style: style, theme: theme)
        button.setTitle(title, for: .normal)
        return button
    }

    func updateUIView(_ uiView: ReleazioButton, context: Context) {}
}

struct ReleazioButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ReleazioButtonUIViewRepresentable(
                title: "Primary Button",
                style: .primary,
                theme: .default
            )
            .frame(width: 200, height: 50)

            ReleazioButtonUIViewRepresentable(
                title: "Secondary Button",
                style: .secondary,
                theme: .default
            )
            .frame(width: 200, height: 50)

            ReleazioButtonUIViewRepresentable(
                title: "Outline Button",
                style: .outline,
                theme: .default
            )
            .frame(width: 200, height: 50)

            ReleazioButtonUIViewRepresentable(
                title: "Destructive Button",
                style: .destructive,
                theme: .default
            )
            .frame(width: 200, height: 50)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif

#endif