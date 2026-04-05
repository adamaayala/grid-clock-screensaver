import AppKit
import QuartzCore

/// Renders the 15×16 character grid using CATextLayers with animated color transitions.
final class GridRenderer {

    /// The root layer containing all glyph layers.
    let containerLayer = CALayer()

    /// 2D array of text layers indexed by [row][col].
    private var glyphLayers: [[CATextLayer]] = []

    /// Currently active positions (to diff against on update).
    private var activePositions = Set<GridModel.Position>()

    private static let activeColor = NSColor.white.cgColor
    private static let inactiveColor = NSColor(white: 0.133, alpha: 1.0).cgColor // #222
    private static let animationDuration: CFTimeInterval = 0.4

    init() {
        containerLayer.isGeometryFlipped = true
        buildGlyphLayers()
    }

    // MARK: - Setup

    private func buildGlyphLayers() {
        glyphLayers = (0..<GridModel.rows).map { row in
            let rowChars = Array(GridModel.characters[row])
            return (0..<GridModel.columns).map { col in
                let layer = CATextLayer()
                layer.string = String(rowChars[col])
                layer.foregroundColor = Self.inactiveColor
                layer.alignmentMode = .center
                layer.isWrapped = false
                layer.truncationMode = .none
                layer.actions = ["foregroundColor": NSNull()] // disable implicit animation
                containerLayer.addSublayer(layer)
                return layer
            }
        }
    }

    // MARK: - Layout

    /// Recalculates all layer frames for the given view bounds.
    func layout(in bounds: NSRect) {
        let gridSide = 0.92 * min(bounds.width, bounds.height)
        let cellWidth = gridSide / CGFloat(GridModel.columns)
        let cellHeight = gridSide / CGFloat(GridModel.columns) // square cells (16×16 grid)
        let originX = (bounds.width - gridSide) / 2.0
        let originY = (bounds.height - gridSide) / 2.0

        let fontSize = cellHeight * 0.45
        let font = NSFont.systemFont(ofSize: fontSize, weight: .light)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        containerLayer.frame = bounds

        for row in 0..<GridModel.rows {
            for col in 0..<GridModel.columns {
                let layer = glyphLayers[row][col]
                layer.frame = CGRect(
                    x: originX + CGFloat(col) * cellWidth,
                    y: originY + CGFloat(row) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                layer.font = font
                layer.fontSize = fontSize
                layer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
            }
        }

        CATransaction.commit()
    }

    // MARK: - Update

    /// Updates which positions are active, animating color changes.
    func update(activePositions newPositions: Set<GridModel.Position>) {
        let toDeactivate = activePositions.subtracting(newPositions)
        let toActivate = newPositions.subtracting(activePositions)

        activePositions = newPositions

        for pos in toDeactivate {
            animateColor(row: pos.row, col: pos.col, to: Self.inactiveColor)
        }
        for pos in toActivate {
            animateColor(row: pos.row, col: pos.col, to: Self.activeColor)
        }
    }

    private func animateColor(row: Int, col: Int, to color: CGColor) {
        guard row < glyphLayers.count, col < glyphLayers[row].count else { return }
        let layer = glyphLayers[row][col]

        let animation = CABasicAnimation(keyPath: "foregroundColor")
        animation.fromValue = layer.foregroundColor
        animation.toValue = color
        animation.duration = Self.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.foregroundColor = color
        layer.add(animation, forKey: "foregroundColor")
    }
}
