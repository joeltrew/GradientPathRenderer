 //  Created by Joel Trew on 24/04/2016.
 
 import MapKit
 
 class JLTGradientPathRenderer: MKOverlayPathRenderer {
    
    var polyline : MKPolyline
    var colors:[UIColor]
    
    var border: Bool = false
    var borderColor: UIColor?
    
    fileprivate var cgColors:[CGColor] {
        return colors.map({ (color) -> CGColor in
            return color.cgColor
        })
    }
    
    //MARK: Initializers
    init(polyline: MKPolyline, colors: [UIColor]) {
        self.polyline = polyline
        self.colors = colors
        
        super.init(overlay: polyline)
    }
    
    //MARK: Override methods
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        /*
         Set path width relative to map zoom scale
         */
        let baseWidth: CGFloat = self.lineWidth / zoomScale
        
        if self.border {
            context.setLineWidth(baseWidth * 2)
            context.setLineJoin(CGLineJoin.round)
            context.setLineCap(CGLineCap.round)
            context.addPath(self.path)
            context.setStrokeColor(self.borderColor?.cgColor ?? UIColor.white.cgColor)
            context.strokePath()
        }
        
        /*
         Create a gradient from the colors provided with evenly spaced stops
         */
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let stopValues = calculateNumberOfStops()
        let locations: [CGFloat] = stopValues
        let gradient = CGGradient(colorsSpace: colorspace, colors: cgColors as CFArray, locations: locations)
        
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
    override func createPath() {
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
    fileprivate func calculateNumberOfStops() -> [CGFloat] {
        
        let stopDifference = (1 / Double(cgColors.count))
        
        return Array(stride(from: 0, to: 1+stopDifference, by: stopDifference))
            .map { (value) -> CGFloat in
                return CGFloat(value)
        }
    }
    
 }
 
 
