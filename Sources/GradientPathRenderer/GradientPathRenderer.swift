 //  Created by Joel Trew on 24/04/2016.
 
import MapKit
 
 /// Draws a given polyline with a gradient fill, use in place of a MKOverlayPathRenderer
 public class GradientPathRenderer: MKOverlayPathRenderer {
    
    /// The polyline to render
    var polyline: MKPolyline
    /// The colors used to draw the gradient
    var colors: [CGColor]
    /// If a border should be rendered to make the line more visible
    var showsBorder: Bool = false
    /// The color of tne border, if showsBorder is true
    var borderColor: CGColor = {
         let space = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
         let comps: [CGFloat] = [1, 1, 1, 1]
         let color = CGColor(colorSpace: space, components: comps)!
         return color
     }()
    
    //MARK: Initializers
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    public init(polyline: MKPolyline, colors: [CGColor]) {
        self.polyline = polyline
        self.colors = colors
        
        super.init(overlay: polyline)
    }
    
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors, with a border with a defined colour
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    ///   - showsBorder: If the polyline should have a border
    ///   - borderColor: The colour of the border
    public init(polyline: MKPolyline, colors: [CGColor], showsBorder: Bool, borderColor: CGColor) {
        self.polyline = polyline
        self.colors = colors
        self.showsBorder = showsBorder
        self.borderColor = borderColor
        
        super.init(overlay: polyline)
    }
    
    //MARK: Override methods
     public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        /*
         Set path width relative to map zoom scale
         */
        let baseWidth: CGFloat = self.lineWidth / zoomScale
        
        if self.showsBorder {
            context.setLineWidth(baseWidth * 2)
            context.setLineJoin(CGLineJoin.round)
            context.setLineCap(CGLineCap.round)
            context.addPath(self.path)
            context.setStrokeColor(self.borderColor)
            context.strokePath()
        }
        
        /*
         Create a gradient from the colors provided with evenly spaced stops
         */
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let stopValues = calculateNumberOfStops()
        let locations: [CGFloat] = stopValues
        let gradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: locations)
        
        /*
         Define path properties and add it to context
         */
        context.setLineWidth(baseWidth)
        context.setLineJoin(CGLineJoin.round)
        context.setLineCap(CGLineCap.round)
        
        context.addPath(self.path)
        
        /*
         Replace path with stroked version so we can clip
         */
        context.saveGState();
        
        context.replacePathWithStrokedPath()
        context.clip();
        
        /*
         Create bounding box around path and get top and bottom points
         */
        let boundingBox = self.path.boundingBoxOfPath
        let gradientStart = boundingBox.origin
        let gradientEnd   = CGPoint(x:boundingBox.maxX, y:boundingBox.maxY)
        
        /*
         Draw the gradient in the clipped context of the path
         */
        if let gradient = gradient {
            context.drawLinearGradient(gradient, start: gradientStart, end: gradientEnd, options: CGGradientDrawingOptions.drawsBeforeStartLocation);
        }
        
        
        context.restoreGState()
        
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
    
    /*
     Create path from polyline
     Thanks to Adrian Schoenig
     (http://adrian.schoenig.me/blog/2013/02/21/drawing-multi-coloured-lines-on-an-mkmapview/ )
     */
     public override func createPath() {
        let path: CGMutablePath  = CGMutablePath()
        var pathIsEmpty: Bool = true
        
        for i in 0...self.polyline.pointCount-1 {
            
            let point: CGPoint = self.point(for: self.polyline.points()[i])
            if pathIsEmpty {
                path.move(to: point)
                pathIsEmpty = false
            } else {
                path.addLine(to: point)
            }
        }
        self.path = path
    }
    
    //MARK: Helper Methods
    private func calculateNumberOfStops() -> [CGFloat] {
        
        let stopDifference = (1 / Double(colors.count))
        
        return Array(stride(from: 0, to: 1+stopDifference, by: stopDifference))
            .map { (value) -> CGFloat in
                return CGFloat(value)
        }
    }
 }

#if canImport(UIKIt)
import UIKit

public extension GradientPathRenderer {
    //MARK: Initializers
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    convenience init(polyline: MKPolyline, colors: [UIColor]) {
        self.init(polyline: polyline, colors: colors.map(\.cgColor))
    }
    
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors, with a border with a defined colour
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    ///   - showsBorder: If the polyline should have a border
    ///   - borderColor: The colour of the border
    convenience init(polyline: MKPolyline, colors: [UIColor], showsBorder: Bool, borderColor: UIColor) {
        self.init(polyline: polyline, colors: colors.map(\.cgColor), showsBorder: showsBorder, borderColor: borderColor.cgColor)
    }
}
#endif

#if canImport(AppKit)
import AppKit

public extension GradientPathRenderer {
    //MARK: Initializers
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    convenience init(polyline: MKPolyline, colors: [NSColor]) {
        self.init(polyline: polyline, colors: colors.map(\.cgColor))
    }
    
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors, with a border with a defined colour
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    ///   - showsBorder: If the polyline should have a border
    ///   - borderColor: The colour of the border
    convenience init(polyline: MKPolyline, colors: [NSColor], showsBorder: Bool, borderColor: NSColor) {
        self.init(polyline: polyline, colors: colors.map(\.cgColor), showsBorder: showsBorder, borderColor: borderColor.cgColor)
    }
}
#endif
