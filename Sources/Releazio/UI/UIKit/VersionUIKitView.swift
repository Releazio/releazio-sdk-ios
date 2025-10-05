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
    
    /// Version label
    private let versionLabel: UILabel
    
    /// Update button
    private let updateButton: UIButton
    
    /// Custom colors for component
    private let customColors: UIComponentColors?
    
    /// Custom localization strings
    private let customStrings: UILocalizationStrings?
    
    /// Localization manager (with auto-detected locale)
    private let localization: LocalizationManager
    
    /// Update button action
    public var onUpdateTap: (() -> Void)?
    
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
            customColors: customColors,
            customStrings: customStrings,
            frame: frame
        )
    }
    
    /// Initialize version view
    /// - Parameters:
    ///   - version: Current app version string
    ///   - isUpdateAvailable: Whether update is available
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - frame: View frame
    public init(
        version: String,
        isUpdateAvailable: Bool = false,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        frame: CGRect = .zero
    ) {
        self.versionLabel = UILabel()
        self.updateButton = UIButton(type: .system)
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
        // Version label
        let versionText = customStrings?.versionText ?? localization.versionText
        versionLabel.text = "\(versionText) \(version)"
        versionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        versionLabel.layer.cornerRadius = 10
        versionLabel.clipsToBounds = true
        
        // Update button
        let buttonText = customStrings?.updateButtonText ?? localization.updateButtonText
        updateButton.setTitle(buttonText, for: .normal)
        updateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        updateButton.layer.cornerRadius = 10
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.isHidden = !isUpdateAvailable
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        
        addSubview(versionLabel)
        addSubview(updateButton)
        
        updateColors()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Version label
            versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            versionLabel.topAnchor.constraint(equalTo: topAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            versionLabel.heightAnchor.constraint(equalToConstant: 44),
            
            // Update button
            updateButton.leadingAnchor.constraint(equalTo: versionLabel.trailingAnchor, constant: 12),
            updateButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            updateButton.centerYAnchor.constraint(equalTo: versionLabel.centerYAnchor),
            updateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
            // Default Olimp yellow
            updateButton.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        }
        
        // Update button text color
        if let customColor = customColors?.updateButtonTextColor {
            updateButton.setTitleColor(customColor, for: .normal)
        } else {
            // Default black text on yellow button
            updateButton.setTitleColor(.black, for: .normal)
        }
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
        update(version: updateState.currentVersionName, isUpdateAvailable: updateState.isUpdateAvailable)
    }
    
    // MARK: - Actions
    
    @objc private func updateButtonTapped() {
        onUpdateTap?()
    }
}

#endif

