import SwiftUI

@main
struct InSiteApp: App {
    @StateObject private var session = LocalizationSessionModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
