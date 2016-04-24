# JLTGradientPathRenderer  

Renders MKPolyline with a fancy multicoloured gradient fill similar to the Nike + Running App.
A drop in replacement for MKPolylineRenderer, supports multiple colour stops and an optional border.  

![](http://i.imgur.com/6fFwni0.png)

### Installation
1. Add JLTGradientPathRenderer.swift to your project
2. Inside `rendererForOverlay` delegate method, use JLTGradientPathRenderer as you would an MKPolyLineRenderer
```swift
func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
            /* define a list of colors you want in your gradient */
            let gradientColors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.yellowColor(), UIColor.redColor()]
            /* Initialise a JLTGradientPathRenderer with the colors */
            let polylineRenderer = JLTGradientPathRenderer(polyline: overlay as! MKPolyline, colors: gradientColors)
        	/* set a linewidth */
            polylineRenderer.lineWidth = 7
            return polylineRenderer
    }
}
```

3. Optionally include `border` and `borderColor` variables to render a border on the polyline
```swift
polylineRenderer.border = true
polylineRenderer.borderColor = UIColor.redColor() /* defaults to white if not specified*/
```
