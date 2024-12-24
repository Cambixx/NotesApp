import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var position = CGPoint(x: bounds.minX, y: bounds.minY)
        var lineHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if position.x + size.width > bounds.maxX {
                position.x = bounds.minX
                position.y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(at: position, proposal: .unspecified)
            position.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> CGSize {
        let width = proposal.width ?? .infinity
        var position = CGPoint.zero
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for size in sizes {
            if position.x + size.width > width {
                position.x = 0
                position.y += lineHeight + spacing
                lineHeight = 0
            }
            
            position.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        totalHeight = position.y + lineHeight
        return CGSize(width: width, height: totalHeight)
    }
} 