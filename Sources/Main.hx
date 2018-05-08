package;

import kha.Framebuffer;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.Assets;
import kha.System;

class Main {
	static var vertices: Array<Float>;
	static var texcoords: Array<Float>;
	static var indices: Array<Int>;

	public static function main() {
		System.init({title: "MeshLoader", width: 800, height: 600}, function () {
			Assets.loadEverything(function () {
				start();
				System.notifyOnRender(render);
			});
		});
		
	}
	
	static function start(): Void {
		var data = new OgexData(Assets.blobs.tiger_ogex.toString());
		vertices = data.geometryObjects[0].mesh.vertexArrays[0].values;
		texcoords = data.geometryObjects[0].mesh.vertexArrays[2].values;
		indices = data.geometryObjects[0].mesh.indexArray.values;
	}

	static inline function transform(vec: FastVector3): FastVector3 {
		var sinus = Math.sin(System.time);
		var cosinus = Math.cos(System.time);
		var x = cosinus * vec.x - sinus * vec.z;
		var y = -vec.y;
		var z = cosinus * vec.z + sinus * vec.x;
		return new FastVector3(x, y, z);
	}

	static function render(frame: Framebuffer): Void {
		var g = frame.g1;
		g.begin();
		
		for (y in 0...System.windowHeight()) {
			for (x in 0...System.windowWidth()) {
				Triangles.depthBuffer[y * System.windowWidth() + x] = Math.POSITIVE_INFINITY;
			}
		}

		for (i in 0...Std.int(indices.length / 3)) {
			var i1 = indices[i * 3 + 0];
			var i2 = indices[i * 3 + 1];
			var i3 = indices[i * 3 + 2];
			
			var vec1 = transform(new FastVector3(vertices[i1 * 3 + 0], vertices[i1 * 3 + 1], vertices[i1 * 3 + 2]));
			var tex1 = new FastVector2(texcoords[i1 * 2 + 0], texcoords[i1 * 2 + 1]);
			
			var vec2 = transform(new FastVector3(vertices[i2 * 3 + 0], vertices[i2 * 3 + 1], vertices[i2 * 3 + 2]));
			var tex2 = new FastVector2(texcoords[i2 * 2 + 0], texcoords[i2 * 2 + 1]);
			
			var vec3 = transform(new FastVector3(vertices[i3 * 3 + 0], vertices[i3 * 3 + 1], vertices[i3 * 3 + 2]));
			var tex3 = new FastVector2(texcoords[i3 * 2 + 0], texcoords[i3 * 2 + 1]);
			
			var scale = 128;
			var w = System.windowWidth();
			var h = System.windowHeight();
			Triangles.draw(g, vec1.x * scale + w / 2, vec1.y * scale + h / 2, vec1.z, tex1.x, tex1.y,
								vec2.x * scale + w / 2, vec2.y * scale + h / 2, vec2.z, tex2.x, tex2.y,
								vec3.x * scale + w / 2, vec3.y * scale + h / 2, vec3.z, tex2.x, tex3.y);
		}

		g.end();
	}
}
