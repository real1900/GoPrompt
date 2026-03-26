import SwiftUI

/// Full settings screen with all teleprompter configuration options
/// Updated to match the high-fidelity native Stitch GoPrompt UI.
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: TeleprompterSettings
    @EnvironmentObject var storeKitManager: StoreKitManager
    @State private var showingResetAlert = false
    @State private var showingProUpgrade = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Screen Header matching Stitch HTML
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(DesignSystem.Typography.largeTitle)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Text("Configuration & Performance")
                                .font(DesignSystem.Typography.label)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .textCase(.uppercase)
                                .tracking(2.0)
                        }
                        .padding(.top, 24)
                        
                        // Prompter Settings Section
                        settingsSection(title: "Prompter Settings") {
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "arrow.left.and.right.righttriangle.left.righttriangle.right",
                                    title: "Mirroring",
                                    subtitle: "Horizontal Reflection",
                                    isLast: false
                                ) {
                                    Toggle("", isOn: $settings.mirrorText)
                                        .labelsHidden()
                                        .tint(DesignSystem.Colors.accentContainer)
                                }
                                
                                SettingsRow(
                                    icon: "speedometer",
                                    title: "Speed",
                                    subtitle: "Words per minute",
                                    isLast: false
                                ) {
                                    Stepper(value: $settings.scrollSpeed, in: TeleprompterSettings.scrollSpeedRange, step: 5) {
                                        Text("\(Int(settings.scrollSpeed)) WPM")
                                            .font(DesignSystem.Typography.label)
                                            .foregroundColor(DesignSystem.Colors.secondary)
                                            .bold()
                                    }
                                    .labelsHidden()
                                    .frame(width: 100)
                                    .overlay(alignment: .leading) {
                                        Text("\(Int(settings.scrollSpeed)) WPM")
                                            .font(DesignSystem.Typography.label)
                                            .foregroundColor(DesignSystem.Colors.secondary)
                                            .bold()
                                            .offset(x: -60)
                                    }
                                }
                                
                                SettingsRow(
                                    icon: "textformat.size",
                                    title: "Font Size",
                                    subtitle: "Optimal reading scale",
                                    isLast: true
                                ) {
                                    Stepper(value: $settings.fontSize, in: TeleprompterSettings.fontSizeRange, step: 2) {
                                        Text("\(Int(settings.fontSize))pt")
                                    }
                                    .labelsHidden()
                                    .frame(width: 100)
                                    .overlay(alignment: .leading) {
                                        Text("\(Int(settings.fontSize))pt")
                                            .font(DesignSystem.Typography.label)
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                            .offset(x: -50)
                                    }
                                }
                            }
                        }
                        
                        // Camera Settings Section
                        settingsSection(title: "Camera Settings") {
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "4k.tv",
                                    title: "Resolution",
                                    subtitle: "Capture Quality",
                                    isLast: false
                                ) {
                                    Picker("", selection: $settings.videoQuality) {
                                        ForEach(VideoQuality.allCases) { quality in
                                            Text(quality.rawValue).tag(quality)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(DesignSystem.Colors.secondaryText)
                                }
                                
                                SettingsRow(
                                    icon: "camera.aperture",
                                    title: "Frame Rate",
                                    subtitle: "Cinematic Standard",
                                    isLast: false
                                ) {
                                    Picker("", selection: $settings.frameRate) {
                                        Text("24 FPS").tag(24)
                                        Text("30 FPS").tag(30)
                                        Text("60 FPS").tag(60)
                                    }
                                    .pickerStyle(.menu)
                                    .tint(DesignSystem.Colors.secondaryText)
                                }
                                
                                SettingsRow(
                                    icon: "video.badge.checkmark",
                                    title: "Stabilization",
                                    subtitle: "Digital Gimbal Mode",
                                    isLast: true
                                ) {
                                    Toggle("", isOn: $settings.stabilizationEnabled)
                                        .labelsHidden()
                                        .tint(DesignSystem.Colors.accentContainer)
                                }
                            }
                        }
                        
                        // Account Section
                        settingsSection(title: "Account") {
                            VStack(spacing: 0) {
                                Button(action: {
                                    showingProUpgrade = true
                                }) {
                                    SettingsRow(
                                        icon: storeKitManager.isProUnlocked ? "checkmark.seal.fill" : "star.circle.fill",
                                        title: "GoPrompt Pro",
                                        subtitle: storeKitManager.isProUnlocked ? "Lifetime Unlocked" : "Unlock No Watermark",
                                        iconColor: storeKitManager.isProUnlocked ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary,
                                        isLast: false
                                    ) {
                                        if !storeKitManager.isProUnlocked {
                                            Text("UPGRADE")
                                                .font(DesignSystem.Typography.label)
                                                .foregroundColor(DesignSystem.Colors.accent)
                                                .tracking(1.0)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(DesignSystem.Colors.accent.opacity(0.15))
                                                .cornerRadius(8)
                                        } else {
                                            Text("MANAGE")
                                                .font(DesignSystem.Typography.label)
                                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                                .tracking(1.0)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    Task {
                                        await storeKitManager.restorePurchases()
                                    }
                                }) {
                                    SettingsRow(
                                        icon: "arrow.clockwise.circle",
                                        title: "Restore Purchases",
                                        subtitle: "Retrieve previous purchases",
                                        iconColor: DesignSystem.Colors.secondary,
                                        isLast: true
                                    ) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Footer
                        VStack(spacing: 8) {
                            Text("GOPROMPT BUILD V1.0.0")
                                .font(.system(size: 10, weight: .medium, design: .default))
                                .foregroundColor(DesignSystem.Colors.secondaryText.opacity(0.4))
                                .tracking(2.0)
                            
                            Button(action: {
                                showingResetAlert = true
                            }) {
                                Text("RESET SETTINGS")
                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                    .foregroundColor(DesignSystem.Colors.destructive)
                                    .tracking(1.0)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal, DesignSystem.Layout.paddingLarge)
                }
            }
            // Hide default nav bar since we use custom Stitch header styles internally if needed
            .navigationBarHidden(true)
            .alert("Reset Settings?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    settings.resetToDefaults()
                }
            } message: {
                Text("This will reset all settings to their default values.")
            }
            .sheet(isPresented: $showingProUpgrade) {
                ProUpgradeView()
            }
        }
    }
    
    // MARK: - Section Container
    
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundColor(DesignSystem.Colors.secondary)
                .textCase(.uppercase)
                .tracking(1.0)
                .padding(.leading, 4)
            
            content()
                .glassPanel(cornerRadius: DesignSystem.Layout.cornerRadiusStandard)
        }
    }
}

// MARK: - Custom List Row for Settings
struct SettingsRow<Action: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = DesignSystem.Colors.accent
    let isLast: Bool
    @ViewBuilder let action: () -> Action
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon Box
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DesignSystem.Colors.surfaceHighest)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(iconColor)
                    )
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                // Right Action View
                action()
            }
            .padding(20)
            
            if !isLast {
                Divider()
                    .background(Color.white.opacity(0.05))
                    .padding(.horizontal, 20)
            }
        }
        // Hover/Active effect placeholder
        .contentShape(Rectangle())
    }
}

// MARK: - Pro Upgrade Paywall (StoreKit 2)
import StoreKit

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeKitManager: StoreKitManager
    
    // For visual effects
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Close button)
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding()
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // Hero Icon
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.accent.opacity(0.15))
                                .frame(width: 120, height: 120)
                                .scaleEffect(pulseScale)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentContainer],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .padding(.top, 20)
                        
                        // Title
                        VStack(spacing: 12) {
                            Text("GoPrompt Pro")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            Text("Unlock your full potential and create stunning, professional videos.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 24) {
                            FeatureRow(icon: "sparkles.tv", title: "No Watermark", subtitle: "Save all your videos crystal clear, permanently removing the GoPrompt watermark.")
                            FeatureRow(icon: "infinity", title: "Unlimited Recording", subtitle: "Record as many scripts and videos as you want without restrictions.")
                            FeatureRow(icon: "wand.and.stars.inverse", title: "Pro Updates", subtitle: "Get immediate access to all future pro-level features.")
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Footer / Purchase Button Area
                VStack(spacing: 16) {
                    if storeKitManager.isProUnlocked {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(DesignSystem.Colors.accent)
                            Text("Pro Unlocked")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primaryText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(DesignSystem.Colors.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                        .padding(.horizontal)
                        
                    } else if let product = storeKitManager.product {
                        Button(action: {
                            Task {
                                try? await storeKitManager.purchase()
                            }
                        }) {
                            HStack {
                                if storeKitManager.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Upgrade for \(product.displayPrice)")
                                        .font(.system(size: 19, weight: .bold, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentContainer],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 15, y: 8)
                        }
                        .padding(.horizontal)
                        .disabled(storeKitManager.isPurchasing)
                    } else {
                        // Loading product...
                        ProgressView("Loading...")
                            .padding()
                    }
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await storeKitManager.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.bottom, 24)
                .background(
                    DesignSystem.Colors.background
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: -10)
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
        }
        .onChange(of: storeKitManager.isProUnlocked) { _, unlocked in
            if unlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(DesignSystem.Colors.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineSpacing(4)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(TeleprompterSettings())
}
