import Cocoa
import SpriteKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 600, height: 650),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)
window.center()
window.title = "Space Invaders (macOS)"
window.makeKeyAndOrderFront(nil)

let skView = SKView(frame: window.contentView!.bounds)
skView.autoresizingMask = [.width, .height]
window.contentView?.addSubview(skView)

let scene = GameScene(size: CGSize(width: 600, height: 650))
scene.scaleMode = .resizeFill
skView.presentScene(scene)

app.activate(ignoringOtherApps: true)
app.run()
