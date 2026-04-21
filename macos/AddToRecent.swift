import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ n: Notification) {
        defer { NSApp.terminate(nil) }
        guard ProcessInfo.processInfo.arguments.count > 1 else { return }
        let path = ProcessInfo.processInfo.arguments[1]
        guard FileManager.default.fileExists(atPath: path) else { return }
        NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: path))
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
