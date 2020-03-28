//
//  GeometryView.swift
//  Prismal
//
//  Created by Marcus Rossel on 13.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Geometry View

final class GeometryView: UIView {
   
   // MARK: - Drawing Options
   
   struct DrawingOptions: OptionSet {
      
      static let reverseDrawingOrder        = DrawingOptions(rawValue: 1 << 0)
      
      static let strokePolygons             = DrawingOptions(rawValue: 1 << 1)
      static let strokeStructure            = DrawingOptions(rawValue: 1 << 2)
      
      static let fillPolygons               = DrawingOptions(rawValue: 1 << 3)
      static let fillStructure              = DrawingOptions(rawValue: 1 << 4)
      
      static let replacePolygonsWithCircles = DrawingOptions(rawValue: 1 << 5)

      let rawValue: Int
   }
   
   // MARK: - Properties
   
   var layers: Int = 1 {
      didSet {
         layers = max(1, layers)
         setNeedsDisplay()
      }
   }
   
   var scale: CGFloat = 1.0 {
      didSet {scale = max(0.001, scale) }
   }
   
   var structureVertexCount: Int = 3 {
      didSet {
         structureVertexCount = max(3, structureVertexCount)
         setNeedsDisplay()
      }
   }
   
   var polygonVertexCount: Int = 3 {
      didSet {
         polygonVertexCount = max(3, polygonVertexCount)
         setNeedsDisplay()
      }
   }
   
   var drawingOptions: DrawingOptions = [.strokePolygons]
   
   var strokeColorScheme: (inner: UIColor, outer: UIColor)?
   var fillColorScheme: (inner: UIColor, outer: UIColor)?
   
   /// Returns the distance from the center of the entire shape to a circle around that center, on
   /// which the centers of all outer polygons of one layer will lie.
   /// The value depends on the number of layers to be drawn, and is safe to be used as a multiple
   /// up to the intended number of layers.
   private var polygonCornerDistance: CGFloat {
      let shorterEdgeDistance = min(bounds.width, bounds.height) / 2.0
      let segmentedDistance = shorterEdgeDistance / CGFloat(layers)
      
      return scale * segmentedDistance
   }
   
   /// A sequence of the layers' indices, based on the drawing order.
   private var layerIndices: [Int] {
      return drawingOptions.contains(.reverseDrawingOrder)
         ? (0..<layers).reversed()
         : Array(0..<layers)
   }
   
   // MARK: - Methods
   
   override func draw(_ rect: CGRect) {      
      // Tracks if the previous layer was even drawn.
      var previousLayerWasDrawn = true
      
      for layerIndex in layerIndices {
         // If the previous layer wasn't drawn and the drawing order isn't reversed, no more layers
         // will be drawn.
         guard previousLayerWasDrawn || drawingOptions.contains(.reverseDrawingOrder) else {
            return
         }
      
         // Gets the corner points for the layer's structural polygon.
         let structureCorners = CGPoint.cornerPointsForRegularPolygon(
            vertexCount: structureVertexCount,
            center: bounds.center,
            cornerDistance: CGFloat(layerIndex) * polygonCornerDistance
         )
         
         // Catches the case of the structure polygon being only a single point.
         guard structureCorners.count >= 2 else {
            // Makes sure the structure polygon is in fact only a single point.
            guard structureCorners.count == 1 else { fatalError() }
            
            previousLayerWasDrawn = drawLayer(
               withIndex: layerIndex, polygonCenters: structureCorners
            )
            continue
         }
         
         // Turns the structure corners into consecutive lines, and segments those lines according
         // to the current layer.
         // The resulting collection contains the centers for all of the polygons of this layer,
         // except for the structure polygon corner points.
         let structureEdges = Line.linesConsecutivelyConnecting(structureCorners)
         let structureEdgeSegmentationPoints = structureEdges.map { edge -> [CGPoint] in
            edge.middlePointsSegmenting(into: layerIndex)
         }
         
         // Combines the structure edge segmentation points and the structure polygon corner points,
         // while also putting them into a consecutive order.
         // The resulting collection contains the center points for all polygons of this layer.
         let pointPairs = zip(structureCorners, structureEdgeSegmentationPoints)
         let polygonCenters: [CGPoint] = pointPairs.flatMap { cornerPoint, edgePoints in
            [cornerPoint] + edgePoints
         }
         
         // Draws the layer, while also recording if any polygon was actually drawn.
         previousLayerWasDrawn = drawLayer(withIndex: layerIndex, polygonCenters: polygonCenters)
         
         // Draws the structure polygon's edges if required.
         if drawingOptions.contains(.strokePolygons) {
            guard let path = UIBezierPath.closing(over: structureCorners) else { fatalError() }
            path.stroke()
         }
      }
   }
   
   /// Draws all of the things that should be drawn for the given layer.
   /// Returns `true` if at least one polygon was drawn.
   @discardableResult
   private func drawLayer(withIndex layerIndex: Int, polygonCenters: [CGPoint]) -> Bool {
      // Sets specific stroke and fill colors, if there should be any.
      let specificStrokeColor: UIColor? = specificColor(
         forLayerWithIndex: layerIndex, forStroke: true
      )
      let specificFillColor: UIColor? = specificColor(
         forLayerWithIndex: layerIndex, forStroke: false
      )
      
      // Tracks if at least one polygon was drawn for the given layer.
      var didDrawPolygon = false
      
      // The loop that draws each polygon in the layer.
      for polygonCenter in polygonCenters {
         // Tests if the polygon center will produce a polygon that would even lie within the view's
         // bounds. If not it does not have to be drawn, as it wouldn't be visible.
         guard polygonIsInBounds(center: polygonCenter) else { continue }
         
         // Draws the polygon.
         let polygonPath = pathForPolygon(center: polygonCenter)
         let strokeColor = specificStrokeColor ?? .random
         let fillColor = specificFillColor ?? .random
         
         drawPolygon(path: polygonPath, strokeColor: strokeColor, fillColor: fillColor)
         didDrawPolygon = true
      }
      
      return didDrawPolygon
   }
   
   /// Checks if a polygon with the given center would even be in the view's bounds (and therefore
   /// visible).
   private func polygonIsInBounds(center: CGPoint) -> Bool {
      // Creates a rect bounding the polygon.
      let polygonSize = CGSize(width: polygonCornerDistance, height: polygonCornerDistance)
      let polygonRect = CGRect(center: center, size: polygonSize)
      
      // If the polygon rectangle doesn't intersect the view's bounds, it will not be visible.
      return polygonRect.intersects(bounds)
   }
   
   /// Gets the path for a polygon with the given center.
   private func pathForPolygon(center: CGPoint) -> UIBezierPath {
      // Differentiates the returned path based on drawing options.
      if drawingOptions.contains(.replacePolygonsWithCircles) {
         // Sets a circular path.
         return UIBezierPath(
            arcCenter: center, radius: polygonCornerDistance,
            startAngle: 0, endAngle: 2 * .pi, clockwise: true
         )
      } else {
         // Sets a polygonal path.
         return .regularPolygon(
            vertexCount: polygonVertexCount, center: center, cornerDistance: polygonCornerDistance
         )
      }
   }
   
   /// Actually draws the polygon with a given path and color.
   /// Drawing options are taken into account.
   private func drawPolygon(path: UIBezierPath, strokeColor: UIColor, fillColor: UIColor) {
      // Strokes the polygon if requested.
      if drawingOptions.contains(.strokePolygons) {
         strokeColor.set()
         path.stroke()
      }
      
      // Fills the polygon if requested.
      if drawingOptions.contains(.fillPolygons) {
         fillColor.set()
         path.fill()
      }
   }
   
   /// Calculates the specific color that will be applied to each polygon in the given layer.
   private func specificColor(forLayerWithIndex layer: Int, forStroke: Bool) -> UIColor? {
      // Gets the color scheme appropriate for stroking or filling.
      guard
         let color: (inner: UIColor, outer: UIColor) = forStroke
            ? strokeColorScheme
            : fillColorScheme
      else {
         return nil
      }
      
      // Shortcuts on trivial cases.
      guard layers > 1 && color.inner != color.outer else { return color.inner }

      // Creates data needed for the following construction.
      let segments = layers - 1
      let componentPairs = zip(color.inner.hsbaComponents, color.outer.hsbaComponents)

      // Constructs an array of color components mixed proportionally from the inner and outer color
      // to fit the given layer.
      let components: [CGFloat] = componentPairs.map { inner, outer in
         let innerPortion = CGFloat(segments - layer) / CGFloat(segments)
         let outerPortion = CGFloat(layer)            / CGFloat(segments)
         
         return (innerPortion * inner) + (outerPortion * outer)
      }
      
      // Constructs a color from the mixed layer color components.
      return UIColor(
         hue:        components[0],
         saturation: components[1],
         brightness: components[2],
         alpha:      components[3]
      )
   }
}
