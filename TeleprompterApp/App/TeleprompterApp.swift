import SwiftUI
import StoreKit

// MARK: - Main Thread Watchdog (DEBUG ONLY)
// Detects when the main thread is blocked for >500ms and prints a warning.
// Remove this class once performance debugging is complete.
class MainThreadWatchdog {
    private let watchdogQueue = DispatchQueue(label: "com.teleprompter.watchdog")
    private let threshold: TimeInterval = 0.5 // 500ms
    private var isRunning = false
    private let fmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleCheck()
    }
    
    private func scheduleCheck() {
        guard isRunning else { return }
        let deadline = CFAbsoluteTimeGetCurrent()
        var mainResponded = false
        
        // Ask main thread to respond
        DispatchQueue.main.async {
            mainResponded = true
        }
        
        // Check after threshold
        watchdogQueue.asyncAfter(deadline: .now() + threshold) { [weak self] in
            guard let self = self else { return }
            if !mainResponded {
                let blocked = CFAbsoluteTimeGetCurrent() - deadline
                // Capture main thread backtrace
                let bt = Thread.callStackSymbols.joined(separator: "\n  ")
                print("🚨 [\(self.fmt.string(from: Date()))] MAIN THREAD BLOCKED for >\(String(format: "%.1f", blocked))s")
                print("🔍 Watchdog thread stack:\n  \(bt)")
                
                // Keep checking until main responds
                self.waitForMainToRespond(since: deadline)
            } else {
                self.scheduleCheck()
            }
        }
    }
    
    private func waitForMainToRespond(since startTime: CFAbsoluteTime) {
        var responded = false
        DispatchQueue.main.async {
            responded = true
        }
        
        watchdogQueue.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            if !responded {
                print("🚨 [\(self.fmt.string(from: Date()))] MAIN THREAD STILL BLOCKED — \(String(format: "%.1f", elapsed))s total")
                self.waitForMainToRespond(since: startTime)
            } else {
                print("✅ [\(self.fmt.string(from: Date()))] Main thread unblocked after \(String(format: "%.1f", elapsed))s")
                self.scheduleCheck()
            }
        }
    }
}

@main
struct TeleprompterApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var cameraService = CinematicCameraService()
    @StateObject private var scriptStorage = ScriptStorageService()
    @StateObject private var settings = TeleprompterSettings()
    @StateObject private var storeKitManager = StoreKitManager.shared
    private let watchdog = MainThreadWatchdog()
    
    init() {
        // Pre-warm the CoreData SQLite stack on boot to prevent lazy initialization deadlocks
        // when jumping directly to RecordingGalleryView's background fetch.
        _ = VideoMetadataCache.shared
    }
    
    private func preWarmCamera() {
        cameraService.warmUp(quality: settings.videoQuality)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(cameraService)
                .environmentObject(scriptStorage)
                .environmentObject(settings)
                .environmentObject(storeKitManager)
                .onAppear {
                    preWarmCamera()
                    watchdog.start()
                }
        }
    }
}

/// Global app state for sharing across views
@MainActor
class AppState: ObservableObject {
    @Published var currentScript: Script?
}

// MARK: - StoreKit Architecture
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published private(set) var product: Product?
    @Published private(set) var isProUnlocked: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    
    private let productId = "6757500363"
    private var updatesTask: Task<Void, Never>? = nil
    
    init() {
        updatesTask = listenForTransactions()
        
        Task {
            await fetchProduct()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    func fetchProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            self.product = products.first
        } catch {
            print("Failed to fetch product: \(error)")
        }
    }
    
    func purchase() async throws {
        guard let product = product else { return }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateCustomerProductStatus()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updateCustomerProductStatus()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    private func updateCustomerProductStatus() async {
        var isPurchased = false
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == productId && transaction.revocationDate == nil {
                    isPurchased = true
                }
            } catch { }
        }
        self.isProUnlocked = isPurchased
    }
    
    nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
