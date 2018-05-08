package;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics1.Graphics;

class Edge {
	public var x1: Int;
	public var y1: Int;
	public var x2: Int;
	public var y2: Int;
	public var z1: Float;
	public var z2: Float;
	public var u1: Float;
	public var v1: Float;
	public var u2: Float;
	public var v2: Float;
	
	public inline function new(x1: Int, y1: Int, z1: Float, u1: Float, v1: Float, x2: Int, y2: Int, z2: Float, u2: Float, v2: Float) {
		if (y1 < y2) {
			this.x1 = x1;
			this.y1 = y1;
			this.z1 = z1;
			this.u1 = u1;
			this.v1 = v1;
			this.x2 = x2;
			this.y2 = y2;
			this.z2 = z2;
			this.u2 = u2;
			this.v2 = v2;
		}
		else {
			this.x1 = x2;
			this.y1 = y2;
			this.z1 = z2;
			this.u1 = u2;
			this.v1 = v2;
			this.x2 = x1;
			this.y2 = y1;
			this.z2 = z1;
			this.u2 = u1;
			this.v2 = v1;
		}
	}
}

class Span {
	public var x1: Int;
	public var x2: Int;
	public var z1: Float;
	public var z2: Float;
	public var u1: Float;
	public var u2: Float;
	public var v1: Float;
	public var v2: Float;
		
	public inline function new(x1: Int, x2: Int, z1: Float, z2: Float, u1: Float, u2: Float, v1: Float, v2: Float) {
		if (x1 < x2) {
			this.x1 = x1;
			this.x2 = x2;
			this.z1 = z1;
			this.z2 = z2;
			this.u1 = u1;
			this.v1 = v1;
			this.u2 = u2;
			this.v2 = v2;
		}
		else {
			this.x1 = x2;
			this.x2 = x1;
			this.z1 = z2;
			this.z2 = z1;
			this.u1 = u2;
			this.v1 = v2;
			this.u2 = u1;
			this.v2 = v1;
		}
	}
}

class Triangles {
	public static var depthBuffer: Array<Float> = [];
	
	static function shadePixel(g: Graphics, x: Int, y: Int, z: Float, u: Float, v: Float) {
		var image = Assets.images.tiger_atlas;
		g.setPixel(x, y, image.at(Math.round(u * image.width), Math.round(v * image.height)));
	}

	static function drawSpan(g: Graphics, span: Span, y: Int) {
		var xdiff = span.x2 - span.x1;
		if (xdiff == 0) return;
		
		var zdiff = span.z2 - span.z1;
		var udiff = span.u2 - span.u1;
		var vdiff = span.v2 - span.v1;
		
		var factor = 0.0;
		var factorStep = 1.0 / xdiff;
		
		var xMin = Std.int(Math.max(0, span.x1));
		var xMax = Std.int(Math.min(span.x2, System.windowWidth()));
		
		factor += factorStep * -Math.min(0, span.x1);
		
		for (x in xMin...xMax) {
			var z = span.z1 + zdiff * factor;
			var u = span.u1 + udiff * factor;
			var v = span.v1 + vdiff * factor;
			if (depthBuffer[y * System.windowWidth() + x] > z) {
				shadePixel(g, x, y, z, u, 1 - v);
				depthBuffer[y * System.windowWidth() + x] = z;
			}
			factor += factorStep;
		}
	}
	
	static function drawSpansBetweenEdges(g: Graphics, e1: Edge, e2: Edge) {
		var e1ydiff: Float = e1.y2 - e1.y1;
		if (e1ydiff == 0.0) return;
		
		var e2ydiff: Float = e2.y2 - e2.y1;
		if (e2ydiff == 0.0) return;
		
		var e1xdiff: Float = e1.x2 - e1.x1;
		var e2xdiff: Float = e2.x2 - e2.x1;
		var z1diff = e1.z2 - e1.z1;
		var z2diff = e2.z2 - e2.z1;
		var e1udiff = e1.u2 - e1.u1;
		var e1vdiff = e1.v2 - e1.v1;
		var e2udiff = e2.u2 - e2.u1;
		var e2vdiff = e2.v2 - e2.v1;
		
		var factor1 = (e2.y1 - e1.y1) / e1ydiff;
		var factorStep1 = 1.0 / e1ydiff;
		var factor2 = 0.0;
		var factorStep2 = 1.0 / e2ydiff;
		
		var yMin = Std.int(Math.max(0, e2.y1));
		var yMax = Std.int(Math.min(e2.y2, System.windowHeight()));
		
		factor1 += factorStep1 * -Math.min(0, e2.y1);
		factor2 += factorStep2 * -Math.min(0, e2.y1);
		
		for (y in yMin...yMax) {
			var span = new Span(e1.x1 + Std.int(e1xdiff * factor1), e2.x1 + Std.int(e2xdiff * factor2),
					  e1.z1 + z1diff * factor1, e2.z1 + z2diff * factor2,
					  e1.u1 + e1udiff * factor1, e2.u1 + e2udiff * factor2,
					  e1.v1 + e1vdiff * factor1, e2.v1 + e2vdiff * factor2);
			drawSpan(g, span, y);
			factor1 += factorStep1;
			factor2 += factorStep2;
		}
	}

	public static function draw(g: Graphics, x1: Float, y1: Float, z1: Float, u1: Float, v1: Float, x2: Float, y2: Float, z2: Float, u2: Float, v2: Float, x3: Float, y3: Float, z3: Float, u3: Float, v3: Float) {
		var edges = [
			new Edge(Math.round(x1), Math.round(y1), z1, u1, v1, Math.round(x2), Math.round(y2), z2, u2, v2),
			new Edge(Math.round(x2), Math.round(y2), z2, u2, v2, Math.round(x3), Math.round(y3), z3, u3, v3),
			new Edge(Math.round(x3), Math.round(y3), z3, u3, v3, Math.round(x1), Math.round(y1), z1, u1, v1)
		];
		
		var maxLength = 0;
		var longEdge = 0;
		
		for (i in 0...3) {
			var length = edges[i].y2 - edges[i].y1;
			if (length > maxLength) {
				maxLength = length;
				longEdge = i;
			}
		}
		
		var shortEdge1 = (longEdge + 1) % 3;
		var shortEdge2 = (longEdge + 2) % 3;
		
		drawSpansBetweenEdges(g, edges[longEdge], edges[shortEdge1]);
		drawSpansBetweenEdges(g, edges[longEdge], edges[shortEdge2]);
	}
}
