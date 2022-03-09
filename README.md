# GradientPathRenderer

Renders MKPolyline with a fancy multicoloured gradient fill similar to the Nike + Running App.
A drop in replacement for MKPolylineRenderer, supports multiple colour stops and an optional border.  

![](http://i.imgur.com/6fFwni0.png)

### Installation
1. Add GradientPathRenderer.swift to your project
2. Inside `rendererForOverlay` delegate method, use GradientPathRenderer as you would an MKPolyLineRenderer
```swift
func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if let overlay = overlay as? MKPolyline {
            /// define a list of colors you want in your gradient
            let gradientColors = [UIColor.green, UIColor.blue, UIColor.yellow, UIColor.red]

            /// Initialise a GradientPathRenderer with the colors
            let polylineRenderer = GradientPathRenderer(polyline: overlay, colors: gradientColors)

            /// set a linewidth
            polylineRenderer.lineWidth = 7
            return polylineRenderer
    }
}
```

3. Optionally include `border` and `borderColor` variables to render a border on the polyline
```swift
polylineRenderer.border = true
polylineRenderer.borderColor = UIColor.red /* defaults to white if not specified*/
```
