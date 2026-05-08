import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    var interval: TimeInterval = 60.0
    var isMonitoring = true
    var toggleMenuItem: NSMenuItem!
    var intervalMenuItems: [NSMenuItem] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        startMonitoring()
    }

    // MARK: - Menu Bar

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateStatusIcon(active: true)

        let menu = NSMenu()

        toggleMenuItem = NSMenuItem(title: "監視中: ON", action: #selector(toggleMonitoring), keyEquivalent: "")
        toggleMenuItem.target = self
        menu.addItem(toggleMenuItem)

        menu.addItem(NSMenuItem.separator())

        let intervalItem = NSMenuItem(title: "間隔", action: nil, keyEquivalent: "")
        let intervalMenu = NSMenu()
        for seconds in [5, 10, 30, 60] {
            let item = NSMenuItem(title: "\(seconds)秒", action: #selector(changeInterval(_:)), keyEquivalent: "")
            item.target = self
            item.tag = seconds
            if seconds == 60 { item.state = .on }
            intervalMenuItems.append(item)
            intervalMenu.addItem(item)
        }
        intervalItem.submenu = intervalMenu
        menu.addItem(intervalItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func updateStatusIcon(active: Bool) {
        guard let button = statusItem.button else { return }
        let symbolName = active ? "dial.high.fill" : "dial.low.fill"
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = true
            button.image = image
            button.title = ""
        }
    }

    // MARK: - Volume Control

    func setInputVolume() {
        let script = NSAppleScript(source: "set volume input volume 100")
        script?.executeAndReturnError(nil)
    }

    // MARK: - Timer

    func startMonitoring() {
        stopMonitoring()
        setInputVolume()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.setInputVolume()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Actions

    @objc func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            startMonitoring()
            toggleMenuItem.title = "監視中: ON"
            updateStatusIcon(active: true)
        } else {
            stopMonitoring()
            toggleMenuItem.title = "監視中: OFF"
            updateStatusIcon(active: false)
        }
    }

    @objc func changeInterval(_ sender: NSMenuItem) {
        interval = TimeInterval(sender.tag)
        for item in intervalMenuItems {
            item.state = .off
        }
        sender.state = .on
        if isMonitoring {
            startMonitoring()
        }
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

let bundleId = Bundle.main.bundleIdentifier ?? "com.local.InputVolumeKeeper"
let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)
if running.count > 1 {
    NSLog("InputVolumeKeeper is already running.")
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
