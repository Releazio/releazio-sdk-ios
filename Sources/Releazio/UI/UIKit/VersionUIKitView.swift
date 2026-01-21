//
//  VersionView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

#if canImport(UIKit)
import UIKit

/// UIKit view for displaying app version with update button
/// Displays version string and optional update button if update is available
public class VersionUIKitView: UIView {
    
    // MARK: - Properties
    
    /// Yellow dot view (for unread post)
    private let yellowDotView: UIView
    
    /// Version label
    private let versionLabel: UILabel
    
    /// Update button
    private let updateButton: UIButton
    
    /// Badge URL (post_url or posts_url) for version tap
    private var badgeURL: String?
    
    /// Post URL from channel data
    private var postUrl: String?
    
    /// Custom colors for component
    private let customColors: UIComponentColors?
    
    /// Custom localization strings
    private let customStrings: UILocalizationStrings?
    
    /// Localization manager (with auto-detected locale)
    private let localization: LocalizationManager
    
    /// Update button action
    public var onUpdateTap: (() -> Void)?
    
    /// Version tap action (opens post URL)
    public var onVersionTap: (() -> Void)?
    
    /// Color scheme
    public var colorScheme: UIUserInterfaceStyle = .light {
        didSet {
            updateColors()
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize version view with UpdateState
    /// - Parameters:
    ///   - updateState: Update state from checkUpdates()
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - frame: View frame
    public convenience init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        frame: CGRect = .zero
    ) {
        // Show update button if update is available (for all types, not just type 1)
        self.init(
            version: updateState.currentVersionName,
            isUpdateAvailable: updateState.isUpdateAvailable,
            badgeURL: updateState.badgeURL,
            postUrl: updateState.channelData.postUrl,
            customColors: customColors,
            customStrings: customStrings,
            frame: frame
        )
    }
    
    /// Initialize version view
    /// - Parameters:
    ///   - version: Current app version string
    ///   - isUpdateAvailable: Whether update is available
    ///   - badgeURL: Badge URL for version tap (optional)
    ///   - postUrl: Post URL from channel data (optional)
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - frame: View frame
    public init(
        version: String,
        isUpdateAvailable: Bool = false,
        badgeURL: String? = nil,
        postUrl: String? = nil,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        frame: CGRect = .zero
    ) {
        self.yellowDotView = UIView()
        self.versionLabel = UILabel()
        self.updateButton = UIButton(type: .system)
        self.badgeURL = badgeURL
        self.postUrl = postUrl
        self.customColors = customColors
        self.customStrings = customStrings
        // Auto-detect locale from system
        let detectedLocale = LocalizationManager.detectSystemLocale()
        self.localization = LocalizationManager(locale: detectedLocale)
        
        super.init(frame: frame)
        
        setupUI(version: version, isUpdateAvailable: isUpdateAvailable)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI(version: String, isUpdateAvailable: Bool) {
        // Yellow dot (for unread post)
        yellowDotView.backgroundColor = .systemYellow
        yellowDotView.layer.cornerRadius = 4
        yellowDotView.translatesAutoresizingMaskIntoConstraints = false
        yellowDotView.isHidden = !shouldShowYellowDot
        
        // Version label (tappable)
        let versionText = customStrings?.versionText ?? localization.versionText
        versionLabel.text = "\(versionText) \(version)"
        versionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.isUserInteractionEnabled = true
        versionLabel.layer.cornerRadius = 10
        versionLabel.clipsToBounds = true
        
        // Add tap gesture to version label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(versionLabelTapped))
        versionLabel.addGestureRecognizer(tapGesture)
        
        // Update button
        let buttonText = customStrings?.updateButtonText ?? localization.updateButtonText
        updateButton.setTitle(buttonText, for: .normal)
        updateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        updateButton.layer.cornerRadius = 10
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.isHidden = !isUpdateAvailable
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        
        addSubview(yellowDotView)
        addSubview(versionLabel)
        addSubview(updateButton)
    }
    
    private var versionLabelLeadingConstraint: NSLayoutConstraint!
    
    private func setupConstraints() {
        // Yellow dot
        yellowDotView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        yellowDotView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        yellowDotView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        yellowDotView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        // Version label - use dynamic constraint
        versionLabelLeadingConstraint = versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        versionLabelLeadingConstraint.isActive = true
        versionLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        versionLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        versionLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Update button
        updateButton.leadingAnchor.constraint(equalTo: versionLabel.trailingAnchor, constant: 12).isActive = true
        updateButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        updateButton.centerYAnchor.constraint(equalTo: versionLabel.centerYAnchor).isActive = true
        updateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        updateConstraintsForYellowDot()

        // Colors call also updates yellow dot constraints. It must run after constraints are created.
        updateColors()
    }
    
    private func updateConstraintsForYellowDot() {
        guard versionLabelLeadingConstraint != nil else { return }
        versionLabelLeadingConstraint.isActive = false
        if shouldShowYellowDot {
            versionLabelLeadingConstraint = versionLabel.leadingAnchor.constraint(equalTo: yellowDotView.trailingAnchor, constant: 12)
        } else {
            versionLabelLeadingConstraint = versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        }
        versionLabelLeadingConstraint.isActive = true
    }
    
    private func updateColors() {
        // Version label background
        if let customColor = customColors?.versionBackgroundColor {
            versionLabel.backgroundColor = customColor
        } else {
            switch colorScheme {
            case .dark:
                versionLabel.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            default:
                versionLabel.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            }
        }
        
        // Version label text color
        if let customColor = customColors?.versionTextColor {
            versionLabel.textColor = customColor
        } else {
            switch colorScheme {
            case .dark:
                versionLabel.textColor = .white
            default:
                versionLabel.textColor = .black
            }
        }
        
        // Update button background
        if let customColor = customColors?.updateButtonColor {
            updateButton.backgroundColor = customColor
        } else {
            // Default black button
            updateButton.backgroundColor = .black
        }
        
        // Update button text color
        if let customColor = customColors?.updateButtonTextColor {
            updateButton.setTitleColor(customColor, for: .normal)
        } else {
            // Default white text on black button
            updateButton.setTitleColor(.white, for: .normal)
        }
        
        // Update yellow dot visibility and constraints
        yellowDotView.isHidden = !shouldShowYellowDot
        updateConstraintsForYellowDot()
    }
    
    /// Whether to show yellow dot (post is unread)
    private var shouldShowYellowDot: Bool {
        // Show dot if postUrl exists and badgeURL equals postUrl (post not read)
        return postUrl != nil && badgeURL == postUrl
    }
    
    // MARK: - Public Methods
    
    /// Update version and update availability
    /// - Parameters:
    ///   - version: Version string
    ///   - isUpdateAvailable: Whether update is available
    public func update(version: String, isUpdateAvailable: Bool) {
        let versionText = customStrings?.versionText ?? localization.versionText
        versionLabel.text = "\(versionText) \(version)"
        updateButton.isHidden = !isUpdateAvailable
    }
    
    /// Update from UpdateState
    /// - Parameter updateState: Update state from checkUpdates()
    public func update(updateState: UpdateState) {
        // Show update button if update is available (for all types)
        self.badgeURL = updateState.badgeURL
        self.postUrl = updateState.channelData.postUrl
        update(version: updateState.currentVersionName, isUpdateAvailable: updateState.isUpdateAvailable)
        updateColors() // Update yellow dot visibility
    }
    
    // MARK: - Actions
    
    @objc private func updateButtonTapped() {
        onUpdateTap?()
    }
    
    @objc private func versionLabelTapped() {
        if let customHandler = onVersionTap {
            customHandler()
        } else if let urlString = badgeURL, let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#endif

