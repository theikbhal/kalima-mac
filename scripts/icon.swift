import AppKit
let out = CommandLine.arguments[1]
let S: CGFloat = 1024
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
let bg = NSBezierPath(roundedRect: NSRect(x: 50, y: 50, width: 924, height: 924), xRadius: 210, yRadius: 210)
NSGradient(starting: NSColor(red: 0.05, green: 0.20, blue: 0.30, alpha: 1),
           ending: NSColor(red: 0.08, green: 0.45, blue: 0.45, alpha: 1))!.draw(in: bg, angle: -50)
NSColor(red: 0.95, green: 0.78, blue: 0.35, alpha: 1).setStroke()
let ring = NSBezierPath(ovalIn: NSRect(x: 212, y: 212, width: 600, height: 600))
ring.lineWidth = 26
ring.stroke()
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 400, weight: .bold),
    .foregroundColor: NSColor.white
]
let str = NSAttributedString(string: "٤", attributes: attrs)
let sz = str.size()
str.draw(at: NSPoint(x: (S - sz.width) / 2, y: (S - sz.height) / 2))
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
