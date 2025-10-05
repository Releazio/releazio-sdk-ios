//
//  BadgeView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// SwiftUI view for update badge indicator
public struct BadgeView: View {
    
    // MARK: - Properties
    
    /// Badge color
    private let badgeColor: Color
    
    /// Badge size
    private let size: CGFloat
    
    /// Action when badge is tapped
    private let onTap: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Initialize badge view
    /// - Parameters:
    ///   - color: Badge color (default: yellow)
    ///   - size: Badge diameter size (default: 12)
    ///   - onTap: Action to perform when badge is tapped
    public init(
        color: Color? = nil,
        size: CGFloat = 12,
        onTap: (() -> Void)? = nil
    ) {
        self.badgeColor = color ?? .yellow
        self.size = size
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        Circle()
            .fill(badgeColor)
            .frame(width: size, height: size)
            .contentShape(Circle())
            .onTapGesture {
                onTap?()
            }
    }
}

// MARK: - UIKit Badge

#if canImport(UIKit)

/// UIKit button with badge indicator
public class BadgeButton: UIButton {
    
    // MARK: - Properties
    
    private let badgeView: UIView
    private let badgeSize: CGFloat
    private var badgeTapAction: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Initialize badge button
    /// - Parameters:
    ///   - color: Badge color (default: system yellow)
    ///   - size: Badge diameter size (default: 12)
    ///   - frame: Button frame
    public init(
        color: UIColor? = nil,
        size: CGFloat = 12,
        frame: CGRect = .zero
    ) {
        self.badgeSize = size
        self.badgeView = UIView()
        super.init(frame: frame)
        
        setupBadge(color: color ?? .systemYellow)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupBadge(color: UIColor) {
        badgeView.backgroundColor = color
        badgeView.layer.cornerRadius = badgeSize / 2
        badgeView.isUserInteractionEnabled = true
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(badgeTapped))
        badgeView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        addSubview(badgeView)
        
        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: badgeSize),
            badgeView.heightAnchor.constraint(equalToConstant: badgeSize),
            badgeView.topAnchor.constraint(equalTo: topAnchor),
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    /// Set action for badge tap
    /// - Parameter action: Action to perform
    public func setBadgeTapAction(_ action: @escaping () -> Void) {
        self.badgeTapAction = action
    }
    
    @objc private func badgeTapped() {
        badgeTapAction?()
    }
}

#endif

