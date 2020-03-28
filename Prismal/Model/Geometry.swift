//
//  Geometry.swift
//  Prismal
//
//  Created by Marcus Rossel on 13.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Line

struct Line: Equatable {
   
   /// The point at which the line is considered to start.
   let start: CGPoint
   
   /// The vector that leads from the line's starting to its end point.
   let vector: CGVector
   
   /// The point at which the line is considered to end.
   var end: CGPoint { return start + vector }
   
   /// Creates a line from its starting point and vector.
   init(start: CGPoint, vector: CGVector) {
      self.start = start
      self.vector = vector
   }
   
   /// Creates a line from its starting and ending points.
   init(start: CGPoint, end: CGPoint) {
      let vector = CGVector(dx: end.x - start.x, dy: end.y - start.y)
      self.init(start: start, vector: vector)
   }
   
   /// Returns a sequence of points that split the line into a given number of segments.
   /// If the given number of segments is less than `2`, the returned sequence is empty.
   func middlePointsSegmenting(into segments: Int) -> [CGPoint] {
      // Shortcuts for the trivial case.
      guard segments >= 2 else { return [] }
      
      // Returns the sequence of points (excluding the line's start and end point), that segment the
      // line in to `segments` number of segments.
      return (1..<segments).map { segment in
         let scalar = CGFloat(segment) / CGFloat(segments)
         return start + (scalar * vector)
      }
   }
   
   /// Creates a sequence of lines connecting the given points consecutively.
   /// The returned sequence is cyclic, and therefore ends with a line connecting the last with the
   /// first point.
   /// If exactly two points are given, a single line is returned.
   /// If less than two points are given, no lines are returned.
   static func linesConsecutivelyConnecting(_ points: [CGPoint]) -> [Line] {
      // Shortcuts for the trivial cases.
      guard points.count > 1 else { return [] }
      guard points.count > 2 else {
         let line = Line(start: points[0], end: points[1])
         return [line]
      }
      
      // Creates a shifted sequence of the points, that start with the second element.
      let shiftedPoints = points[1...] + [points[0]]
      
      // Creates a sequence of point-pairs of the form: (0, 1), (1, 2), ..., (n-1, n), (n, 0).
      let adjacentPairs = zip(points, shiftedPoints)
      
      // Returns a sequence of lines created from adjacent points respectively.
      return adjacentPairs.map(Line.init)
   }
}

// MARK: - Vector Operators

/// Returns the point reached by adding the given vector to the given point.
private func + (point: CGPoint, vector: CGVector) -> CGPoint {
   return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

//// Creates a specific multiple of the given vector.
private func * (multiplier: CGFloat, vector: CGVector) -> CGVector {
   return CGVector(dx: multiplier * vector.dx, dy: multiplier * vector.dy)
}

// MARK: - Point Methods

extension CGPoint {
   
   /// Returns an array of points representing the corners of a homogenous polygon with a given
   /// center, size and number of vertices.
   /// If the given vertex count in less than `3` or the given distance is negative, there exist no
   /// regular polygons so an empty sequence is returned.
   /// If the given distance is `0` a single point, the center point, is returned.
   static func cornerPointsForRegularPolygon(
      vertexCount: Int, center: CGPoint, cornerDistance distance: CGFloat
   ) -> [CGPoint] {
      // Shortcuts for trivial cases.
      guard vertexCount > 0 else { return [] }
      guard vertexCount > 1 else { return [center] }
      guard distance > 0 else { return [center] }
      
      // An angle x, so that: (x * vertexCount) = 360°.
      let angleStride = (2 * .pi) / CGFloat(vertexCount)
      
      // Constructs a sequence of points representing the corner points of the polygon, by using
      // incremental angle offsets and adding a vector of length `distance` to the polygon's center.
      let points: [CGPoint] = (0..<vertexCount).map { vertex in
         // Constructs the angle describing how far the point is offset from 0°.
         let offsetAngle = angleStride * CGFloat(vertex)
         
         // Calculates the vertex' x and y coordinates.
         let x = distance * sin(offsetAngle) + center.x
         let y = distance * cos(offsetAngle) + center.y
         
         return CGPoint(x: x, y: y)
      }
      
      return points
   }
}

// MARK: - Path Methods

extension UIBezierPath {

   static func closing(over points: [CGPoint]) -> UIBezierPath? {
      // Checks a precondition.
      guard points.count > 2 else { return nil }
      
      let path = UIBezierPath()
      
      // Moves to the first point, adds lines to all successors and closes the path at the end.
      path.move(to: points[0])
      points[1...].forEach { point in path.addLine(to: point) }
      path.close()
      
      return path
   }
   
   /// Constructs a path forming a regular polygon with the given properties.
   static func regularPolygon(
      vertexCount: Int, center: CGPoint, cornerDistance: CGFloat
   ) -> UIBezierPath {
      // Gets the polygon's corner points.
      let cornerPoints = CGPoint.cornerPointsForRegularPolygon(
         vertexCount: vertexCount, center: center, cornerDistance: cornerDistance
      )
      
      // Returns a closed path over the corner points.
      guard let path = UIBezierPath.closing(over: cornerPoints) else { fatalError() }
      return path
   }
}
