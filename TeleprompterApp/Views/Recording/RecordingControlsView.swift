import SwiftUI

/// Recording controls bar matching the Stitch GoPrompt Pro UI
struct RecordingControlsView: View {
    @ObservedObject var cameraService: CinematicCameraService
    @ObservedObject var teleprompterEngine: TeleprompterEngine
    @Binding var showCameraControls: Bool
    
    var onSettingsTapped: () -> Void
    var onScriptTapped: () -> Void
    var onRecordTapped: () -> Void
    var onStopTapped: () -> Void
    
    private let peachTint = Color(red: 1.0, green: 0.7, blue: 0.66)
    
    var body: some View {
        if cameraService.isRecording {
            // RECORDING MODE: HUD Bottom Row
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Spacer()
                    // REC Pill
                    HStack(spacing: 6) {
                        Image(systemName: "video.fill")
                            .foregroundColor(DesignSystem.Colors.destructive)
                            .modifier(PulsingModifier())
                        
                        Text(formatDuration(cameraService.recordingDuration))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassPanel(cornerRadius: 30)
                    
                    Spacer()
                    
                    // Stop Square inside Ring
                    Button {
                        onStopTapped()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(DesignSystem.Colors.destructive.opacity(0.3), lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.destructive)
                                .frame(width: 32, height: 32)
                                .shadow(color: DesignSystem.Colors.destructive.opacity(0.5), radius: 20, x: 0, y: 0)
                        }
                    }
                    
                    Spacer()
                    
                    // Pause Script Pill
                    Button(action: {
                        if teleprompterEngine.isPaused {
                            teleprompterEngine.resumeScrolling()
                        } else {
                            teleprompterEngine.pauseScrolling()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: teleprompterEngine.isPaused ? "play.fill" : "pause.fill")
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Text(teleprompterEngine.isPaused ? "RESUME" : "PAUSE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .tracking(1.0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassPanel(cornerRadius: 30)
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .transition(.opacity)
        } else {
            // NOT RECORDING (Stitch Bottom Bar)
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        // Settings
                        Button(action: onSettingsTapped) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(peachTint)
                                .frame(width: 48, height: 48)
                        }
                        
                        // Camera Controls (Aperture/Tools)
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showCameraControls.toggle()
                            }
                        }) {
                            Image(systemName: "camera.aperture")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(showCameraControls ? Color.white : peachTint)
                                .frame(width: 48, height: 48)
                        }
                        
                        Spacer()
                        
                        // MASSIVE RECORD BUTTON
                        Button(action: onRecordTapped) {
                            ZStack {
                                // Outer Thin Ring
                                Circle()
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                                    .frame(width: 72, height: 72)
                                    
                                // Soft Glow
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                    .blur(radius: 8)

                                // Main Trigger
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.35, blue: 0.35))
                                    .frame(width: 52, height: 52)
                                    // Deep shadow to glow
                                    .shadow(color: Color.red.opacity(0.8), radius: 12, x: 0, y: 0)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        Spacer()
                        
                        // Script / Documents
                        Button(action: onScriptTapped) {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(peachTint)
                                .frame(width: 48, height: 48)
                        }
                        
                        // Resolution Pill
                        Button {
                            cycleVideoQuality()
                        } label: {
                            Text(cameraService.videoQuality == .ultra ? "4K60" : "HD30")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(1.0)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(white: 0.15))
                                .clipShape(Capsule())
                        }
                        .frame(minWidth: 64)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.1, opacity: 0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 20)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    Spacer()
                }
            }
            .transition(.opacity)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func cycleVideoQuality() {
        let allQualities = VideoQuality.allCases
        if let currentIndex = allQualities.firstIndex(of: cameraService.videoQuality) {
            let nextIndex = (currentIndex + 1) % allQualities.count
            cameraService.videoQuality = allQualities[nextIndex]
        }
    }
}

struct PulsingModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.3 : 1.0)
            .animation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingControlsView(
            cameraService: CinematicCameraService(),
            teleprompterEngine: TeleprompterEngine(),
            showCameraControls: .constant(false),
            onSettingsTapped: {},
            onScriptTapped: {},
            onRecordTapped: {},
            onStopTapped: {}
        )
    }
}
