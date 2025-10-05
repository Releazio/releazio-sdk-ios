//
//  ChangelogViewController.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

#if canImport(UIKit)
import UIKit

/// UIKit view controller for displaying changelog
public class ChangelogViewController: UIViewController {

    // MARK: - Properties

    /// Changelog to display
    public let changelog: Changelog

    /// Theme configuration
    public let theme: ChangelogUITheme

    /// Close button handler
    public var onClose: (() -> Void)?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = theme.titleFont
        label.textColor = theme.titleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = theme.dateFont
        label.textColor = theme.subtitleColor
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization

    /// Initialize changelog view controller
    /// - Parameters:
    ///   - changelog: Changelog to display
    ///   - theme: Theme configuration
    public init(
        changelog: Changelog,
        theme: ChangelogUITheme = .default
    ) {
        self.changelog = changelog
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
        configureNavigation()
        populateContent()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Track analytics
        Releazio.shared.getConfiguration()?.debugLoggingEnabled
        // Note: Analytics tracking would be implemented here
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = theme.backgroundColor

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func configureNavigation() {
        title = "What's New"

        // Navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        // Close button
        if onClose != nil || presentingViewController != nil {
            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(closeButtonTapped)
            )
            closeButton.tintColor = theme.primaryColor
            navigationItem.rightBarButtonItem = closeButton
        }

        // Navigation bar styling
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: theme.titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.titleColor]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func populateContent() {
        // Clear existing content
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add header
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(createSeparatorView())

        // Add categories
        for category in changelog.sortedCategories {
            if changelog.hasContent(in: category) {
                let categoryView = createCategoryView(category)
                stackView.addArrangedSubview(categoryView)
            }
        }

        // Add author info if available
        if let author = changelog.author {
            let authorView = createAuthorView(author)
            stackView.addArrangedSubview(authorView)
        }

        // Set content
        titleLabel.text = changelog.title
        dateLabel.text = changelog.formattedCreationDate
    }

    // MARK: - View Creation Methods

    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.backgroundColor = theme.dividerColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }

    private func createCategoryView(_ category: ChangelogCategory) -> UIView {
        let containerView = UIView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Category header
        let headerView = createCategoryHeader(category)
        stackView.addArrangedSubview(headerView)

        // Category entries
        let entries = changelog.entries(in: category)
        for entry in entries {
            let entryView = createEntryView(entry)
            stackView.addArrangedSubview(entryView)
        }

        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createCategoryHeader(_ category: ChangelogCategory) -> UIView {
        let containerView = UIView()
        let iconView = UIImageView()
        let titleLabel = UILabel()
        let countLabel = UILabel()

        // Configure icon
        let iconImage = UIImage(systemName: category.iconName)
        iconView.image = iconImage
        iconView.tintColor = UIColor(hex: category.color) ?? .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // Configure title
        titleLabel.text = category.displayName
        titleLabel.font = theme.categoryFont
        titleLabel.textColor = theme.categoryColor
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        // Configure count badge
        let entryCount = changelog.entryCountsByCategory[category] ?? 0
        if entryCount > 1 {
            countLabel.text = "\(entryCount)"
            countLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            countLabel.textColor = .white
            countLabel.backgroundColor = UIColor(hex: category.color) ?? .systemBlue
            countLabel.textAlignment = .center
            countLabel.layer.cornerRadius = 10
            countLabel.clipsToBounds = true
            countLabel.translatesAutoresizingMaskIntoConstraints = false
        }

        // Layout
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(iconView)
        horizontalStack.addArrangedSubview(titleLabel)

        if entryCount > 1 {
            horizontalStack.addArrangedSubview(countLabel)
        } else {
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            horizontalStack.addArrangedSubview(spacer)
        }

        containerView.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            countLabel.widthAnchor.constraint(equalToConstant: 20),
            countLabel.heightAnchor.constraint(equalToConstant: 20),

            horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createEntryView(_ entry: ChangelogEntry) -> UIView {
        let containerView = UIView()
        let priorityView = UIView()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()

        // Configure priority indicator
        if entry.isBreaking {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            imageView.tintColor = .systemRed
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            priorityView.addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 12),
                imageView.heightAnchor.constraint(equalToConstant: 12),
                imageView.centerXAnchor.constraint(equalTo: priorityView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: priorityView.centerYAnchor)
            ])
        } else {
            let color = priorityColor(for: entry.priority)
            priorityView.backgroundColor = color
            priorityView.layer.cornerRadius = 4
            priorityView.translatesAutoresizingMaskIntoConstraints = false
        }

        // Configure title
        if let title = entry.title, !title.isEmpty {
            titleLabel.text = title
            titleLabel.font = theme.entryTitleFont
            titleLabel.textColor = theme.entryTitleColor
            titleLabel.numberOfLines = 0
        }

        // Configure description
        descriptionLabel.text = entry.description
        descriptionLabel.font = theme.entryDescriptionFont
        descriptionLabel.textColor = theme.entryDescriptionColor
        descriptionLabel.numberOfLines = 0

        // Layout
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        if titleLabel.text != nil {
            verticalStack.addArrangedSubview(titleLabel)
        }
        verticalStack.addArrangedSubview(descriptionLabel)

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .top
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(priorityView)
        horizontalStack.addArrangedSubview(verticalStack)

        containerView.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            priorityView.widthAnchor.constraint(equalToConstant: 8),
            priorityView.heightAnchor.constraint(equalToConstant: 8),

            horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createAuthorView(_ author: Author) -> UIView {
        let containerView = UIView()
        let avatarImageView = UIImageView()
        let nameLabel = UILabel()
        let roleLabel = UILabel()

        // Configure avatar
        if let avatarURL = author.avatarURL {
            // For simplicity, we'll skip async image loading in this example
            // In a real implementation, you'd use a library like Kingfisher
            avatarImageView.backgroundColor = theme.subtitleColor.withAlphaComponent(0.3)
            avatarImageView.image = UIImage(systemName: "person.fill")
            avatarImageView.tintColor = theme.subtitleColor.withAlphaComponent(0.6)
        } else {
            avatarImageView.backgroundColor = theme.subtitleColor.withAlphaComponent(0.3)
            avatarImageView.image = UIImage(systemName: "person.fill")
            avatarImageView.tintColor = theme.subtitleColor.withAlphaComponent(0.6)
        }
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        // Configure name
        nameLabel.text = author.name
        nameLabel.font = theme.authorNameFont
        nameLabel.textColor = theme.authorNameColor

        // Configure role
        if let role = author.role {
            roleLabel.text = role
            roleLabel.font = theme.authorRoleFont
            roleLabel.textColor = theme.authorRoleColor
        }

        // Layout
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 2
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        verticalStack.addArrangedSubview(nameLabel)
        if roleLabel.text != nil {
            verticalStack.addArrangedSubview(roleLabel)
        }

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(avatarImageView)
        horizontalStack.addArrangedSubview(verticalStack)

        containerView.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    // MARK: - Helper Methods

    private func priorityColor(for priority: EntryPriority) -> UIColor {
        switch priority {
        case .critical:
            return .systemRed
        case .high:
            return .systemOrange
        case .normal:
            return theme.primaryColor
        case .low:
            return theme.subtitleColor
        }
    }

    // MARK: - Actions

    @objc private func closeButtonTapped() {
        if let onClose = onClose {
            onClose()
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - Changelog UI Theme

public struct ChangelogUITheme {
    public let backgroundColor: UIColor
    public let primaryColor: UIColor
    public let titleColor: UIColor
    public let subtitleColor: UIColor
    public let categoryColor: UIColor
    public let entryTitleColor: UIColor
    public let entryDescriptionColor: UIColor
    public let authorNameColor: UIColor
    public let authorRoleColor: UIColor
    public let dividerColor: UIColor
    public let titleFont: UIFont
    public let dateFont: UIFont
    public let categoryFont: UIFont
    public let entryTitleFont: UIFont
    public let entryDescriptionFont: UIFont
    public let authorNameFont: UIFont
    public let authorRoleFont: UIFont

    public init(
        backgroundColor: UIColor = .systemBackground,
        primaryColor: UIColor = .systemBlue,
        titleColor: UIColor = .label,
        subtitleColor: UIColor = .secondaryLabel,
        categoryColor: UIColor = .label,
        entryTitleColor: UIColor = .label,
        entryDescriptionColor: UIColor = .secondaryLabel,
        authorNameColor: UIColor = .label,
        authorRoleColor: UIColor = .secondaryLabel,
        dividerColor: UIColor = .separator,
        titleFont: UIFont = UIFont.boldSystemFont(ofSize: 24),
        dateFont: UIFont = UIFont.systemFont(ofSize: 14),
        categoryFont: UIFont = UIFont.boldSystemFont(ofSize: 18),
        entryTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 16),
        entryDescriptionFont: UIFont = UIFont.systemFont(ofSize: 16),
        authorNameFont: UIFont = UIFont.boldSystemFont(ofSize: 14),
        authorRoleFont: UIFont = UIFont.systemFont(ofSize: 12)
    ) {
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.categoryColor = categoryColor
        self.entryTitleColor = entryTitleColor
        self.entryDescriptionColor = entryDescriptionColor
        self.authorNameColor = authorNameColor
        self.authorRoleColor = authorRoleColor
        self.dividerColor = dividerColor
        self.titleFont = titleFont
        self.dateFont = dateFont
        self.categoryFont = categoryFont
        self.entryTitleFont = entryTitleFont
        self.entryDescriptionFont = entryDescriptionFont
        self.authorNameFont = authorNameFont
        self.authorRoleFont = authorRoleFont
    }

    /// Default theme
    public static let `default` = ChangelogUITheme()

    /// Dark theme
    public static let dark = ChangelogUITheme(
        backgroundColor: .systemBackground,
        primaryColor: .systemOrange,
        titleColor: .label,
        subtitleColor: .secondaryLabel
    )
}

// MARK: - Convenience Methods

extension ChangelogViewController {

    /// Present changelog modally
    /// - Parameters:
    ///   - changelog: Changelog to display
    ///   - presentingViewController: View controller to present from
    ///   - theme: Theme configuration
    ///   - completion: Completion handler
    public static func present(
        changelog: Changelog,
        from presentingViewController: UIViewController,
        theme: ChangelogUITheme = .default,
        completion: (() -> Void)? = nil
    ) {
        let changelogVC = ChangelogViewController(changelog: changelog, theme: theme)
        let navigationController = UINavigationController(rootViewController: changelogVC)
        navigationController.modalPresentationStyle = .formSheet

        presentingViewController.present(navigationController, animated: true) {
            completion?()
        }
    }

    /// Push changelog onto navigation stack
    /// - Parameters:
    ///   - changelog: Changelog to display
    ///   - navigationController: Navigation controller to push onto
    ///   - theme: Theme configuration
    public static func push(
        changelog: Changelog,
        onto navigationController: UINavigationController,
        theme: ChangelogUITheme = .default
    ) {
        let changelogVC = ChangelogViewController(changelog: changelog, theme: theme)
        navigationController.pushViewController(changelogVC, animated: true)
    }
}

// MARK: - UIColor Extension

private extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

#endif
