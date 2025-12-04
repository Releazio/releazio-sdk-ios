//
//  ReleazioUpdatePromptViewController.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

#if canImport(UIKit)
import UIKit

/// UIKit view controller for Releazio update prompt
/// Supports update types 2 (popup) and 3 (popup force)
public class ReleazioUpdatePromptViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Update state from checkUpdates()
    public let updateState: UpdateState
    
    /// Custom colors for component
    private let customColors: UIComponentColors?
    
    /// Custom localization strings
    private let customStrings: UILocalizationStrings?
    
    /// Localization manager (with auto-detected locale)
    private let localization: LocalizationManager
    
    /// Callback when user chooses to update
    public var onUpdate: (() -> Void)?
    
    /// Callback when user skips (type 3 only)
    public var onSkip: ((Int) -> Void)?
    
    /// Callback when user closes (type 2 only)
    public var onClose: (() -> Void)?
    
    /// Callback when user taps info button
    public var onInfoTap: (() -> Void)?
    
    private var remainingSkipAttempts: Int
    
    // MARK: - UI Components
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        // Will be set in setupUI after initialization
        return label
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        // Will be set in setupUI after initialization
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .system)
        // Will be set in setupUI after initialization
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        // Will be set in setupUI after initialization
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    /// Initialize update prompt view controller
    /// - Parameters:
    ///   - updateState: Update state from checkUpdates()
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - onUpdate: Update action
    ///   - onSkip: Skip action (for type 3)
    ///   - onClose: Close action (for type 2)
    ///   - onInfoTap: Info button action (opens post_url)
    public init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdate: (() -> Void)? = nil,
        onSkip: ((Int) -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        onInfoTap: (() -> Void)? = nil
    ) {
        self.updateState = updateState
        self.customColors = customColors
        self.customStrings = customStrings
        // Auto-detect locale from system
        let detectedLocale = LocalizationManager.detectSystemLocale()
        self.localization = LocalizationManager(locale: detectedLocale)
        self.onUpdate = onUpdate
        self.onSkip = onSkip
        self.onClose = onClose
        self.onInfoTap = onInfoTap
        self.remainingSkipAttempts = updateState.remainingSkipAttempts
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Set texts from custom strings or localization
        titleLabel.text = updateTitle
        let message = updateState.channelData.updateMessage.isEmpty ? updateMessage : updateState.channelData.updateMessage
        messageLabel.text = message
        
        updateButton.setTitle(updateButtonText, for: .normal)
        updateButton.setTitleColor(updateButtonTextColor, for: .normal)
        updateButton.backgroundColor = updateButtonColor
        
        skipButton.setTitle(skipButtonText + " (\(remainingSkipAttempts))", for: .normal)
        skipButton.setTitleColor(.secondaryLabel, for: .normal)
        skipButton.backgroundColor = .clear
        
        view.addSubview(overlayView)
        view.addSubview(containerView)
        
        // Header container
        containerView.addSubview(headerContainer)
        
        // Title (centered)
        headerContainer.addSubview(titleLabel)
        
        // Buttons stack (overlay on title)
        if updateState.channelData.postUrl != nil {
            headerStackView.addArrangedSubview(infoButton)
        }
        
        headerStackView.addArrangedSubview(UIView()) // Center spacer (stretches)
        
        if updateState.updateType == 2 {
            headerStackView.addArrangedSubview(closeButton)
        }
        
        headerContainer.addSubview(headerStackView)
        
        // Content
        containerView.addSubview(messageLabel)
        
        // Buttons
        containerView.addSubview(updateButton)
        if updateState.updateType == 3 && remainingSkipAttempts > 0 {
            containerView.addSubview(skipButton)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Proportional width constraint (85% of screen)
        let proportionalWidth = containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        proportionalWidth.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            // Overlay
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            proportionalWidth,  // 85% of screen width (with high priority)
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 500),  // But max 500pt
            
            // Header container
            headerContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Title (centered in header)
            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: headerContainer.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor, constant: -32),
            
            // Buttons stack (overlay on header)
            headerStackView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerStackView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            
            // Message
            messageLabel.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Buttons
            updateButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            updateButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
        ])
        // Skip button
        if updateState.updateType == 3 && remainingSkipAttempts > 0 {
            skipButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
            skipButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
            skipButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 12).isActive = true
            skipButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            skipButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        }
    }
    
    private func updateUI() {
        
        // Update skip button visibility
        if updateState.updateType == 3 && remainingSkipAttempts > 0 {
            skipButton.isHidden = false
        } else {
            skipButton.isHidden = true
        }
    }
    
    // MARK: - Computed Properties for Custom Strings and Colors
    
    private var updateTitle: String {
        return customStrings?.updateTitle ?? localization.updateTitle
    }
    
    private var updateMessage: String {
        return customStrings?.updateMessage ?? localization.updateMessage
    }
    
    private var updateButtonText: String {
        return customStrings?.updateButtonText ?? localization.updateButtonText
    }
    
    private var skipButtonText: String {
        return customStrings?.skipButtonText ?? localization.skipButtonText
    }
    
    private var skipRemainingText: String {
        if let customFormat = customStrings?.skipRemainingTextFormat {
            return String(format: customFormat, remainingSkipAttempts)
        }
        return localization.skipRemainingText(count: remainingSkipAttempts)
    }
    
    private var updateButtonColor: UIColor {
        return .black
    }
    
    private var updateButtonTextColor: UIColor {
        if let customColor = customColors?.updateButtonTextColor {
            return customColor
        }
        return .white
    }
    
    // MARK: - Actions
    
    @objc private func overlayTapped() {
        // Only allow dismiss for type 2
        if updateState.updateType == 2 {
            closeTapped()
        }
    }
    
    @objc private func infoTapped() {
        onInfoTap?()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true) {
            self.onClose?()
        }
    }
    
    @objc private func updateTapped() {
        onUpdate?()
    }
    
    @objc private func skipTapped() {
        let newRemaining = remainingSkipAttempts - 1
        remainingSkipAttempts = newRemaining
        updateUI()
        onSkip?(newRemaining)
        
        // "Skip" means close the popup
        dismiss(animated: true)
    }
}

#endif

