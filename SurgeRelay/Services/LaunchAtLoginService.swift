import CoreServices
import Foundation
import ServiceManagement

@MainActor
enum LaunchAtLoginService {
    static func isLoginLaunch(
        event: NSAppleEventDescriptor?,
        startedByLaunchd: Bool,
        isRegistered: Bool
    ) -> Bool {
        // A launchd start can arrive without an open-application event.
        guard let event else { return startedByLaunchd && isRegistered }
        return event.eventClass == AEEventClass(kCoreEventClass)
            && event.eventID == AEEventID(kAEOpenApplication)
            && event.paramDescriptor(forKeyword: AEKeyword(keyAEPropData))?.enumCodeValue
                == OSType(keyAELaunchedAsLogInItem)
    }

    static var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if !isEnabled { try SMAppService.mainApp.register() }
        } else if isEnabled {
            try SMAppService.mainApp.unregister()
        }
    }
}

