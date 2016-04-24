 //  Created by Joel Trew on 24/04/2016.
 
 import MapKit
 
 class JLTGradientPathRenderer: MKOverlayPathRenderer {
    
    var polyline : MKPolyline
    var colors:[UIColor]
    
    var border: Bool = false
    var borderColor: UIColor?
    
    private var cgColors:[CGColor] {
        return colors.map({ (color) -> CGColor in
            return color.CGColor
        })
    }
    
    //MARK: Initializers
    init(polyline: MKPolyline, colors: [UIColor]) {
        self.polyline = polyline
        self.colors = colors
        
        super.init(overlay: polyline)
    }
    
    //MARK: Override methods
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        
        /*
         Set path width relative to map zoom scale
         */
        let baseWidth: CGFloat = self.lineWidth / zoomScale
        
        if self.border {
            CGContextSetLineWidth(context, baseWidth * 2)
            CGContextSetLineJoin(context, CGLineJoin.Round)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextAddPath(context, self.path)
            CGContextSetStrokeColorWithColor(context, self.borderColor?.CGColor ?? UIColor.whiteColor().CGColor)
            CGContextStrokePath(context)
        }
        
        /*
         Create a gradient from the colors provided with evenly spaced stops
         */
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let stopValues = calculateNumberOfStops()
        let locations: [CGFloat] = stopValues
        let gradient = CGGradientCreateWithColors(colorspace, cgColors, locations)
        
        /*
         Define path properties and add it to context
         */
        CGContextSetLineWidth(context, baseWidth)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        CGContextSetLineCap(context, CGLineCap.Round)
        
        CGContextAddPath(context, self.path)
        
        /*
         Replace path with stroked version so we can clip
         */
        CGContextSaveGState(context);
        
        CGContextReplacePathWithStrokedPath(context)
        CGContextClip(context);
        
        /*
         Create bounding box around path and get top and bottom points
         */
        let boundingBox = CGPathGetPathBoundingBox(self.path)
        let gradientStart = boundingBox.origin
        let gradientEnd   = CGPoint(x:boundingBox.maxX, y:boundingBox.maxY)
        
        /*
         Draw the gradient in the clipped context of the path
         */
        CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, CGGradientDrawingOptions.DrawsBeforeStartLocation);
        
        
        CGContextRestoreGState(context)
        
        
        super.drawMapRect(mapRect, zoomScale: zoomScale, inContext: context)
    }
    
    /*
     Create path from polyline
     Thanks to Adrian Schoenig
     (http://adrian.schoenig.me/blog/2013/02/21/drawing-multi-coloured-lines-on-an-mkmapview/ )
     */
    override func createPath() {
        let path: CGMutablePathRef  = CGPathCreateMutable()
        var pathIsEmpty: Bool = true
        
        for i in 0...self.polyline.pointCount-1 {
            
            let point: CGPoint = pointForMapPoint(self.polyline.points()[i])
            if pathIsEmpty {
                CGPathMoveToPoint(path, nil, point.x, point.y)
                pathIsEmpty = false
            } else {
                CGPathAddLineToPoint(path, nil, point.x, point.y)
            }
        }
        self.path = path
    }
    
    //MARK: Helper Methods
    private func calculateNumberOfStops() -> [CGFloat] {
        
        let stopDifference = (1 / Double(cgColors.count))
        
        return Array(0.stride(to: 1+stopDifference, by: stopDifference))
            .map { (value) -> CGFloat in
                return CGFloat(value)
        }
    }
    
 }
 
 
