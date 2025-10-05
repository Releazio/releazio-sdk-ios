//
//  ColorHelpers.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

// MARK: - Cross-Platform Color Helpers

extension Color {
    #if canImport(UIKit)
    public static let systemBackground = Color(UIColor.systemBackground)
    public static let label = Color(UIColor.label)
    public static let secondaryLabel = Color(UIColor.secondaryLabel)
    public static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    public static let separator = Color(UIColor.separator)
    public static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    public static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    #else
    public static let systemBackground = Color(NSColor.controlBackgroundColor)
    public static let label = Color(NSColor.controlTextColor)
    public static let secondaryLabel = Color(NSColor.secondaryLabelColor)
    public static let tertiaryLabel = Color(NSColor.tertiaryLabelColor)
    public static let separator = Color(NSColor.separatorColor)
    public static let secondarySystemFill = Color(NSColor.controlBackgroundColor)
    public static let secondarySystemBackground = Color(NSColor.unemphasizedSelectedContentBackgroundColor)
    #endif
}