import AppKit
import Sparkle
import SwiftUI

enum SurgeRelayWindow {
    static let main = "main"
    static let settings = "settings"
}

extension Notification.Name {
    static let showSurgeRelayAbout = Notification.Name("showSurgeRelayAbout")
    static let checkForSurgeRelayUpdates = Notification.Name("checkForSurgeRelayUpdates")
}

@MainActor
enum SurgeRelayTerminationCoordinator {
    private static var allowsNextTermination = false

    static func allowNextTermination() {
        allowsNextTermination = true
    }

    static func terminateCompletely() {
        allowNextTermination()
        NSApp.terminate(nil)
    }

    static func consumeCompleteTerminationRequest() -> Bool {
        defer { allowsNextTermination = false }
        return allowsNextTermination
    }
}

/// Sparkle must be allowed to terminate the server process once so it can
/// replace the application bundle and relaunch the updated version.
@MainActor
private final class SurgeRelayUpdaterDelegate: NSObject, SPUUpdaterDelegate {
    func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
        SurgeRelayTerminationCoordinator.allowNextTermination()
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        SurgeRelayTerminationCoordinator.allowNextTermination()
    }
}

@MainActor
enum SurgeRelaySettingsNavigation {
    private static var hasPendingAboutRequest = false

    static func requestAbout() {
        hasPendingAboutRequest = true
        NotificationCenter.default.post(name: .showSurgeRelayAbout, object: nil)
    }

    static func consumeAboutRequest() -> Bool {
        defer { hasPendingAboutRequest = false }
        return hasPendingAboutRequest
    }
}

@MainActor
private struct SurgeRelayAppInfoCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("关于 Surge Relay") {
                NSApp.setActivationPolicy(.regular)
                SurgeRelaySettingsNavigation.requestAbout()
                openWindow(id: SurgeRelayWindow.settings)
                NSApp.activate()
            }
        }
    }
}

private struct SurgeRelaySettingsCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("设置…") {
                openWindow(id: SurgeRelayWindow.settings)
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

@MainActor
final class SurgeRelayAppDelegate: NSObject, NSApplicationDelegate {
    private let wasRegisteredAtLaunch = LaunchAtLoginService.isEnabled
    private var openMainWindow: (() -> Void)?
    private var needsMainWindow = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        MenuBarStatusController.shared.setEnabled(RelayDeviceConfiguration.mode == .server)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let launchedAsLoginItem = LaunchAtLoginService.isLoginLaunch(
            event: NSAppleEventManager.shared().currentAppleEvent,
            startedByLaunchd: getppid() == 1,
            isRegistered: wasRegisteredAtLaunch
        )
        guard launchedAsLoginItem else {
            requestMainWindow()
            return
        }

        if RelayDeviceConfiguration.mode == .client {
            try? LaunchAtLoginService.setEnabled(false)
            NSApp.terminate(nil)
        }
    }

    func configureWindowActions(model: AppModel, updater: SPUUpdater, openWindow: OpenWindowAction) {
        let presentWindow: (String) -> Void = { id in
            NSApp.setActivationPolicy(.regular)
            openWindow(id: id)
            NSApp.activate()
        }
        let openMainWindow = { presentWindow(SurgeRelayWindow.main) }
        self.openMainWindow = openMainWindow
        MenuBarStatusController.shared.configure(
            model: model,
            updater: updater,
            openMainWindow: openMainWindow,
            openSettingsWindow: { presentWindow(SurgeRelayWindow.settings) }
        )

        if needsMainWindow {
            requestMainWindow()
        }
    }

    private func requestMainWindow() {
        guard let openMainWindow else {
            needsMainWindow = true
            return
        }
        needsMainWindow = false
        DispatchQueue.main.async {
            openMainWindow()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        RelayDeviceConfiguration.mode == .client
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if SurgeRelayTerminationCoordinator.consumeCompleteTerminationRequest()
            || RelayDeviceConfiguration.mode == .client {
            return .terminateNow
        }
        sender.windows.filter { $0.level == .normal }.forEach { $0.orderOut(nil) }
        sender.setActivationPolicy(.accessory)
        return .terminateCancel
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return true }
        requestMainWindow()
        return false
    }
}

@main
struct SurgeRelayApp: App {
    @NSApplicationDelegateAdaptor(SurgeRelayAppDelegate.self) private var appDelegate
    @Environment(\.openWindow) private var openWindow
    @State private var model: AppModel
    private let updaterDelegate: SurgeRelayUpdaterDelegate
    private let updaterController: SPUStandardUpdaterController

    init() {
        let model = AppModel()
        _model = State(initialValue: model)
        let updaterDelegate = SurgeRelayUpdaterDelegate()
        self.updaterDelegate = updaterDelegate
        updaterController = SPUStandardUpdaterController(
            startingUpdater: !PersistenceStore.isTesting,
            updaterDelegate: updaterDelegate,
            userDriverDelegate: nil
        )
        Task { @MainActor in
            await model.start()
        }
    }

    var body: some Scene {
        let _ = appDelegate.configureWindowActions(
            model: model,
            updater: updaterController.updater,
            openWindow: openWindow
        )
        Window("Surge Relay", id: SurgeRelayWindow.main) {
            RootView()
                .environment(model)
                .environment(\.locale, Locale(identifier: "zh_CN"))
            .frame(minWidth: 920, minHeight: 640)
            .onReceive(NotificationCenter.default.publisher(for: .checkForSurgeRelayUpdates)) { _ in
                updaterController.updater.checkForUpdates()
            }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified(showsTitle: false))
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1100, height: 720)
        .restorationBehavior(.disabled)
        .defaultLaunchBehavior(.suppressed)
        .commands {
            SurgeRelayAppInfoCommands()
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            SurgeRelaySettingsCommands()
            CommandGroup(after: .newItem) {
                Button("更新全部模块") {
                    Task { await model.updateAll(forceReconversion: true) }
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                .disabled(model.isWorking || model.deviceMode == .client)
            }
        }

        Window("设置", id: SurgeRelayWindow.settings) {
            SettingsView()
                .environment(model)
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .frame(minWidth: 760, minHeight: 560)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 620)
        .windowResizability(.contentMinSize)
        .restorationBehavior(.disabled)
        .defaultLaunchBehavior(.suppressed)

    }
}
