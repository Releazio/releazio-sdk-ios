//
//  UpdatePromptViewController.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

#if canImport(UIKit)
import UIKit

/// UIKit view controller for prompting app updates
public class UpdatePromptViewController: UIViewController {

    // MARK: - Properties

    /// Release information
    public let release: Release

    /// Update type
    public let updateType: UpdateType

    /// Whether this is a mandatory update
    public let isMandatory: Bool

    /// Theme configuration
    public let theme: UpdatePromptUITheme

    /// Update callback
    public var onUpdate: (() -> Void)?

    /// Dismiss callback
    public var onDismiss: (() -> Void)?

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = theme.backgroundColor
        view.layer.cornerRadius = theme.cornerRadius
        view.layer.shadowColor = theme.shadowColor.cgColor
        view.layer.shadowRadius = theme.shadowRadius
        view.layer.shadowOpacity = theme.shadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: theme.shadowOffsetY)
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var headerView = UIView()
    private lazy var contentView = UIView()
    private lazy var buttonView = UIView()

    // Header components
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.titleFont
        label.textColor = theme.titleColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.versionFont
        label.textColor = theme.versionColor
        return label
    }()

    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.sizeFont
        label.textColor = theme.subtitleColor
        return label
    }()

    // Content components
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.messageFont
        label.textColor = theme.messageColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var changelogButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(theme.primaryColor, for: .normal)
        button.titleLabel?.font = theme.changelogTitleFont
        button.contentHorizontalAlignment = .left
        return button
    }()

    private lazy var changelogPreviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.changelogFont
        label.textColor = theme.changelogColor
        label.numberOfLines = 3
        return label
    }()

    private lazy var warningView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()

    private lazy var warningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.warningFont
        label.textColor = .systemRed
        label.numberOfLines = 0
        return label
    }()

    // Button components
    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = theme.buttonFont
        button.layer.cornerRadius = theme.buttonCornerRadius
        return button
    }()

    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = theme.buttonFont
        button.layer.cornerRadius = theme.buttonCornerRadius
        return button
    }()

    // Background overlay
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    // MARK: - Initialization

    /// Initialize update prompt view controller
    /// - Parameters:
    ///   - release: Release information
    ///   - updateType: Type of update
    ///   - isMandatory: Whether update is mandatory
    ///   - theme: Theme configuration
    public init(
        release: Release,
        updateType: UpdateType,
        isMandatory: Bool = false,
        theme: UpdatePromptUITheme = .default
    ) {
        self.release = release
        self.updateType = updateType
        self.isMandatory = isMandatory
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateContent()
        setupActions()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePresentation()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = .clear

        // Add subviews
        view.addSubview(overlayView)
        view.addSubview(containerView)
        containerView.addSubview(stackView)

        // Add stack view components
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(createSeparatorView())
        stackView.addArrangedSubview(contentView)
        stackView.addArrangedSubview(createSeparatorView())
        stackView.addArrangedSubview(buttonView)

        setupHeaderView()
        setupContentView()
        setupButtonView()

        // Setup constraints
        NSLayoutConstraint.activate([
            // Overlay constraints
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Container constraints
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 400),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Setup overlay tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(tapGesture)
    }

    private func setupHeaderView() {
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(versionLabel)
        headerView.addSubview(sizeLabel)

        NSLayoutConstraint.activate([
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

            // Version constraints
            versionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            versionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

            // Size constraints
            sizeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            sizeLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 12),
            sizeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            sizeLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
    }

    private func setupContentView() {
        contentView.addSubview(messageLabel)
        contentView.addSubview(changelogButton)
        contentView.addSubview(changelogPreviewLabel)
        contentView.addSubview(warningView)

        // Setup warning view
        warningView.addSubview(warningImageView)
        warningView.addSubview(warningLabel)

        NSLayoutConstraint.activate([
            // Message constraints
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Changelog button constraints
            changelogButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            changelogButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            changelogButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            changelogButton.heightAnchor.constraint(equalToConstant: 32),

            // Changelog preview constraints
            changelogPreviewLabel.topAnchor.constraint(equalTo: changelogButton.bottomAnchor, constant: 8),
            changelogPreviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            changelogPreviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Warning view constraints
            warningView.topAnchor.constraint(equalTo: changelogPreviewLabel.bottomAnchor, constant: 16),
            warningView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            warningView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            warningView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            // Warning image constraints
            warningImageView.leadingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: 16),
            warningImageView.topAnchor.constraint(equalTo: warningView.topAnchor, constant: 12),
            warningImageView.widthAnchor.constraint(equalToConstant: 16),
            warningImageView.heightAnchor.constraint(equalToConstant: 16),

            // Warning label constraints
            warningLabel.leadingAnchor.constraint(equalTo: warningImageView.trailingAnchor, constant: 12),
            warningLabel.topAnchor.constraint(equalTo: warningView.topAnchor, constant: 12),
            warningLabel.trailingAnchor.constraint(equalTo: warningView.trailingAnchor, constant: -16),
            warningLabel.bottomAnchor.constraint(equalTo: warningView.bottomAnchor, constant: -12)
        ])
    }

    private func setupButtonView() {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually

        buttonStackView.addArrangedSubview(secondaryButton)
        buttonStackView.addArrangedSubview(primaryButton)

        buttonView.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: theme.buttonHeight)
        ])
    }

    private func populateContent() {
        // Populate header
        iconImageView.image = UIImage(systemName: headerIconName)
        iconImageView.tintColor = headerIconColor
        titleLabel.text = headerTitle
        versionLabel.text = release.versionWithBuild

        if let formattedSize = release.formattedUpdateSize {
            sizeLabel.text = "Download size: \(formattedSize)"
            sizeLabel.isHidden = false
        } else {
            sizeLabel.isHidden = true
        }

        // Populate content
        messageLabel.text = updateMessage

        if let releaseNotes = release.releaseNotes, !releaseNotes.isEmpty {
            changelogButton.setTitle("What's New", for: .normal)
            changelogButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            changelogButton.semanticContentAttribute = .forceRightToLeft
            changelogPreviewLabel.text = releaseNotes
            changelogButton.isHidden = false
            changelogPreviewLabel.isHidden = false
        } else {
            changelogButton.isHidden = true
            changelogPreviewLabel.isHidden = true
        }

        // Show warning for mandatory updates
        if isMandatory {
            warningView.isHidden = false
            warningLabel.text = "This update is required to continue using the app."
        }

        // Configure buttons
        if isMandatory {
            secondaryButton.isHidden = true
            primaryButton.setTitle("Update Now", for: .normal)
            primaryButton.backgroundColor = .systemRed
            primaryButton.setTitleColor(.white, for: .normal)
        } else {
            secondaryButton.isHidden = false
            secondaryButton.setTitle("Later", for: .normal)
            secondaryButton.backgroundColor = theme.secondaryButtonBackgroundColor
            secondaryButton.setTitleColor(theme.secondaryButtonTextColor, for: .normal)

            primaryButton.setTitle(updateButtonText, for: .normal)
            primaryButton.backgroundColor = primaryButtonBackgroundColor
            primaryButton.setTitleColor(.white, for: .normal)
        }
    }

    private func setupActions() {
        changelogButton.addTarget(self, action: #selector(changelogButtonTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
    }

    // MARK: - Helper Methods

    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.backgroundColor = theme.dividerColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }

    // MARK: - Computed Properties

    private var headerIconName: String {
        switch updateType {
        case .critical:
            return "exclamationmark.shield.fill"
        case .major:
            return "star.fill"
        case .minor:
            return "arrow.up.circle.fill"
        case .patch:
            return "ladybug.fill"
        case .none:
            return "info.circle.fill"
        }
    }

    private var headerIconColor: UIColor {
        switch updateType {
        case .critical:
            return .systemRed
        case .major:
            return .systemOrange
        case .minor:
            return .systemBlue
        case .patch:
            return .systemGreen
        case .none:
            return theme.primaryColor
        }
    }

    private var headerTitle: String {
        if isMandatory {
            return "Mandatory Update Required"
        }

        switch updateType {
        case .critical:
            return "Critical Security Update"
        case .major:
            return "Major Update Available"
        case .minor:
            return "New Update Available"
        case .patch:
            return "Bug Fix Update"
        case .none:
            return "Update Available"
        }
    }

    private var updateMessage: String {
        if isMandatory {
            return "A mandatory update is required to continue using the app. Please update to the latest version to ensure you have the latest security patches and features."
        }

        switch updateType {
        case .critical:
            return "A critical security update is available that addresses important vulnerabilities. We recommend updating immediately."
        case .major:
            return "A major new version is available with exciting new features, improvements, and an enhanced user experience."
        case .minor:
            return "New features and improvements are available in this update to enhance your app experience."
        case .patch:
            return "This update includes bug fixes and performance improvements to make the app more stable."
        case .none:
            return "An update is available with improvements and new features."
        }
    }

    private var updateButtonText: String {
        if isMandatory {
            return "Update Now"
        }

        switch updateType {
        case .critical:
            return "Update Now"
        case .major:
            return "Update to Latest"
        case .minor:
            return "Update"
        case .patch:
            return "Update"
        case .none:
            return "Update"
        }
    }

    private var primaryButtonBackgroundColor: UIColor {
        switch updateType {
        case .critical:
            return .systemRed
        case .major:
            return .systemOrange
        default:
            return theme.primaryColor
        }
    }

    // MARK: - Animations

    private func animatePresentation() {
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }

    private func animateDismissal(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.containerView.alpha = 0
            self.overlayView.alpha = 0
        }) { _ in
            completion()
        }
    }

    // MARK: - Actions

    @objc private func overlayTapped() {
        if !isMandatory {
            dismiss()
        }
    }

    @objc private func changelogButtonTapped() {
        // Present changelog view controller
        let changelogVC = ChangelogViewController(
            changelog: Changelog(
                id: "temp",
                releaseId: release.id,
                title: release.title,
                content: release.description ?? "",
                entries: [], // Would be populated from API
                author: nil
            )
        )
        present(changelogVC, animated: true)
    }

    @objc private func primaryButtonTapped() {
        onUpdate?()
        dismiss()
    }

    @objc private func secondaryButtonTapped() {
        onDismiss?()
        dismiss()
    }

    private func dismiss() {
        animateDismissal {
            self.dismiss(animated: false)
        }
    }
}

// MARK: - Update Prompt UI Theme

public struct UpdatePromptUITheme {
    public let backgroundColor: UIColor
    public let primaryColor: UIColor
    public let titleColor: UIColor
    public let subtitleColor: UIColor
    public let versionColor: UIColor
    public let messageColor: UIColor
    public let changelogTitleColor: UIColor
    public let changelogColor: UIColor
    public let warningColor: UIColor
    public let primaryButtonTextColor: UIColor
    public let primaryButtonBackgroundColor: UIColor
    public let secondaryButtonTextColor: UIColor
    public let secondaryButtonBackgroundColor: UIColor
    public let dividerColor: UIColor
    public let shadowColor: UIColor
    public let cornerRadius: CGFloat
    public let shadowRadius: CGFloat
    public let shadowOpacity: Float
    public let shadowOffsetY: CGFloat
    public let buttonHeight: CGFloat
    public let buttonCornerRadius: CGFloat
    public let titleFont: UIFont
    public let versionFont: UIFont
    public let sizeFont: UIFont
    public let messageFont: UIFont
    public let changelogTitleFont: UIFont
    public let changelogFont: UIFont
    public let warningFont: UIFont
    public let buttonFont: UIFont

    public init(
        backgroundColor: UIColor = .systemBackground,
        primaryColor: UIColor = .systemBlue,
        titleColor: UIColor = .label,
        subtitleColor: UIColor = .secondaryLabel,
        versionColor: UIColor = .secondaryLabel,
        messageColor: UIColor = .label,
        changelogTitleColor: UIColor = .systemBlue,
        changelogColor: UIColor = .secondaryLabel,
        warningColor: UIColor = .systemRed,
        primaryButtonTextColor: UIColor = .white,
        primaryButtonBackgroundColor: UIColor = .systemBlue,
        secondaryButtonTextColor: UIColor = .label,
        secondaryButtonBackgroundColor: UIColor = .secondarySystemFill,
        dividerColor: UIColor = .separator,
        shadowColor: UIColor = .black,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 10,
        shadowOpacity: Float = 0.1,
        shadowOffsetY: CGFloat = 5,
        buttonHeight: CGFloat = 50,
        buttonCornerRadius: CGFloat = 12,
        titleFont: UIFont = UIFont.boldSystemFont(ofSize: 20),
        versionFont: UIFont = UIFont.systemFont(ofSize: 16),
        sizeFont: UIFont = UIFont.systemFont(ofSize: 14),
        messageFont: UIFont = UIFont.systemFont(ofSize: 16),
        changelogTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 16),
        changelogFont: UIFont = UIFont.systemFont(ofSize: 14),
        warningFont: UIFont = UIFont.systemFont(ofSize: 16),
        buttonFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
    ) {
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.versionColor = versionColor
        self.messageColor = messageColor
        self.changelogTitleColor = changelogTitleColor
        self.changelogColor = changelogColor
        self.warningColor = warningColor
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor
        self.dividerColor = dividerColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.shadowOffsetY = shadowOffsetY
        self.buttonHeight = buttonHeight
        self.buttonCornerRadius = buttonCornerRadius
        self.titleFont = titleFont
        self.versionFont = versionFont
        self.sizeFont = sizeFont
        self.messageFont = messageFont
        self.changelogTitleFont = changelogTitleFont
        self.changelogFont = changelogFont
        self.warningFont = warningFont
        self.buttonFont = buttonFont
    }

    /// Default theme
    public static let `default` = UpdatePromptUITheme()

    /// Dark theme
    public static let dark = UpdatePromptUITheme(
        backgroundColor: .secondarySystemBackground,
        primaryColor: .systemOrange,
        primaryButtonBackgroundColor: .systemOrange
    )
}

// MARK: - Convenience Methods

extension UpdatePromptViewController {

    /// Present update prompt modally
    /// - Parameters:
    ///   - release: Release information
    ///   - updateType: Type of update
    ///   - isMandatory: Whether update is mandatory
    ///   - presentingViewController: View controller to present from
    ///   - theme: Theme configuration
    ///   - onUpdate: Update callback
    ///   - onDismiss: Dismiss callback
    ///   - completion: Presentation completion
    public static func present(
        release: Release,
        updateType: UpdateType,
        isMandatory: Bool = false,
        from presentingViewController: UIViewController,
        theme: UpdatePromptUITheme = .default,
        onUpdate: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        let updatePromptVC = UpdatePromptViewController(
            release: release,
            updateType: updateType,
            isMandatory: isMandatory,
            theme: theme
        )
        updatePromptVC.onUpdate = onUpdate
        updatePromptVC.onDismiss = onDismiss

        updatePromptVC.modalPresentationStyle = .overFullScreen
        updatePromptVC.modalTransitionStyle = .crossDissolve

        presentingViewController.present(updatePromptVC, animated: false) {
            completion?()
        }
    }
}

#endif