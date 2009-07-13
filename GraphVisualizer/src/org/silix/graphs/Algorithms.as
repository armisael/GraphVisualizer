import org.silix.graphs.GraphComponent;
import org.silix.graphs.edges.GenericEdge;
import org.silix.graphs.vertexes.GenericVertex;

public const algorithms: Array = [	{name:'Random Draw', label:randomDraw},
									{name:'Circle Draw', label:circleDraw},
									{name:'Fruchterman-Reingold', label: fruchtermanReingoldDraw},
									{name:'Barycenter method', label: barycenterDraw}
								 ];
public const distances: Array = [	{name:'Euclidean Distance', label:euclideanDistance},
									{name:'Manhattan Distance', label:manhattanDistance}
								 ];
[Bindable] public var alg_width: Number = 200;
[Bindable] public var alg_height: Number = 200;
[Bindable] public var alg_l: Number = 100;			// the natural length of the spring.
[Bindable] public var alg_k1: Number = 3;		// the stiffness of the spring. ( k1 big => d(v1,v2) -> l ).
[Bindable] public var alg_k2: Number = 500;		// the strenght of eletrical repulsion.
[Bindable] public var alg_move_factor: Number = 0.001;
[Bindable] public var alg_iterations: int = 20;
[Bindable] public var alg_fixed: int = 5;
[Bindable] public var alg_internal_iterations: int = 10;
[Bindable] public var alg_d:Object = euclideanDistance;

private const MAX_DISTANCE:Number = 10000;

/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 * DISTANCES ALGORITHMS
 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
public function euclideanDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number
{
	return Math.min(MAX_DISTANCE, Math.sqrt( Math.pow(x1-x2, 2) + Math.pow(y1-y2, 2) ));
}

public function manhattanDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number
{
	return Math.min(MAX_DISTANCE, Math.abs(x1-x2) + Math.abs(y1-y2) );
}

		
		
/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 * DRAWING ALGORITHMS : RANDOM DRAW
 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
public function randomDraw(g:GraphComponent):Function
{
 	return randomDraw_iterate(g, 1);
}

private function randomDraw_iterate(g:GraphComponent, cnt:int):Function
{
	if (cnt == 0) return null;
	
	randomDraw_elaborate(g, alg_width, alg_height);
	
	return function(g:GraphComponent):Function { return randomDraw_iterate(g, cnt-1) };
}

private function randomDraw_elaborate(g:GraphComponent, w:Number, h:Number):void
{
	for (var i:String in g.V) {
		if (g.V[i].status == GenericVertex.STATUS_ADDED) {
 			g.V[i].toX = Math.random()*w;
 			g.V[i].toY = Math.random()*h;
 		}
 	}
}



/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 * DRAWING ALGORITHMS : CIRCLE DRAW
 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
public function circleDraw(g:GraphComponent):Function
{
 	return circleDraw_iterate(g, 1);
}

private function circleDraw_iterate(g:GraphComponent, cnt:int):Function
{
	if (cnt == 0) return null;
	
	circleDraw_elaborate(g, alg_width, alg_height);
	
	return function(g:GraphComponent):Function { return circleDraw_iterate(g, cnt-1) };
}

private function circleDraw_elaborate(g:GraphComponent, w:Number, h:Number):void
{
	var card: int = g.vertexCard;
	//for (var i:String in g.V) card++;
	
	var offset: Number = Math.PI * 2 / card;
	var theta: Number = -Math.PI;
	for (var i:String in g.V) {
		g.V[i].toX = Math.cos(theta) * w/2;
 		g.V[i].toY = Math.sin(theta) * h/2;
 		theta += offset;
 	}
}



/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 * DRAWING ALGORITHMS : Fruchterman – Reingold
 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
public function fruchtermanReingoldDraw(g:GraphComponent):Function
{	
	randomDraw_elaborate(g, alg_width, alg_height);
	//circleDraw_elaborate(g, alg_width, alg_height);
	return function(g:GraphComponent):Function { return fruchtermanReingoldDraw_iterate(g, alg_iterations); } ;
}

private function fruchtermanReingoldDraw_iterate(g:GraphComponent, cnt:int):Function
{
	if (cnt == 0) return null;
	
	for (var i:String in g.V) {
		g.V[i].toX = g.V[i].x;
		g.V[i].toY = g.V[i].y;
	}
	
	for (var j:int = 0; j < alg_internal_iterations; j++)
		fruchtermanReingoldDraw_elaborate(g, alg_l, alg_k1, alg_k2, alg_d, alg_move_factor);
	
	return function(g:GraphComponent):Function { return fruchtermanReingoldDraw_iterate(g, cnt-1) };
}

private function fruchtermanReingoldDraw_elaborate(g:GraphComponent, l:Number, k1:Number, k2:Number, d:Object, mf:Number):void
{
	var fx: Number;
	var fy: Number;
	var vd: Number;
	var n: Number;
	var v: GenericVertex;
	var w: GenericVertex;
	var e: GenericEdge;
	var forces: Array = new Array();
	
	for (var i:String in g.V) {
		fx = 0;
		fy = 0;
		
		v = g.V[i];
		// force by springs between v and all his neighbours.
		 for (var j:String in v.E) {
			e = v.E[j];
			vd = d( e.v1.toX, e.v1.toY, e.v2.toX, e.v2.toY);
			n = k1 * (vd - l);
			fx += n * (e.v2.toX - e.v1.toX) / vd;
			fy += n * (e.v2.toY - e.v1.toY) / vd;
		} 
		
		//trace(fx, fy);
		
		for (var k:String in g.V) {
			if (i == k) continue;
			w = g.V[k];
			
			vd = d(v.toX, v.toY, w.toX, w.toY);
			// check if g is directed and if w is neighbour of v. If true, evaluate the force between v and w 
			// (w isn't a neighbour of v in g, but it is for our algorithm).
			if (g.directed && w.isNeighbourOf(v)) {
				n = k1 * (vd - l);
				fx += n * (w.toX - v.toX) / vd;
				fy += n * (w.toY - v.toY) / vd;
			} 
			
			// evaluate the electrical repulsion between v and w.
			fx += k2 / Math.pow(vd, 2) * (v.toX - w.toX) / vd;
			fy += k2 / Math.pow(vd, 2) * (v.toY - w.toY) / vd;
		}
			
		forces[i] = {fx: fx, fy: fy};
	}
	
	for (i in g.V) {
		g.V[i].toX += Math.ceil(forces[i].fx*mf);
		g.V[i].toY += Math.ceil(forces[i].fy*mf);
		//g.V[i].x += forces[i].fx*mf;
		//g.V[i].y += forces[i].fy*mf;
	}
}



/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 * DRAWING ALGORITHMS : Barycenter draw
 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
public function barycenterDraw(g:GraphComponent):Function
{	
	circleDraw_elaborate(g, alg_width, alg_height);
	return function(g:GraphComponent):Function { return barycenterDraw_iterate(g, alg_iterations); } ;
}

private function barycenterDraw_iterate(g:GraphComponent, cnt:int):Function
{
	if (cnt == 0) return null;
	
	for (var i:String in g.V) {
		g.V[i].toX = g.V[i].x;
		g.V[i].toY = g.V[i].y;
	}
	
	for (var j:int = 0; j < alg_internal_iterations; j++)
		barycenterDraw_elaborate(g, ((alg_fixed > 3) ? alg_fixed : 3),  alg_move_factor);
	
	return function(g:GraphComponent):Function { return barycenterDraw_iterate(g, cnt-1) };
}

private function barycenterDraw_elaborate(g:GraphComponent, fixed: int, mf:Number):void
{
	mf *= 10;			// I don't know why, but we need a bigger number...
	var fx: Number;
	var fy: Number;
	var v: GenericVertex;
	var w: GenericVertex;
	var e: GenericEdge;
	var forces: Array = new Array();
	var between: int = Math.floor(g.vertexCard / fixed);	// The number of free vertexes between two fixed ones.
	var cnt: int = between+1; 								// Set cnt > between so the first will be fixed.						
	
	for (var i:String in g.V) {
		fx = 0;
		fy = 0;
		
		if (cnt <= between) {
			v = g.V[i];
			// force by springs between v and all his neighbours.
			for (var j:String in v.E) {
				e = v.E[j];
				fx += (e.v2.toX - v.toX);
				fy += (e.v2.toY - v.toY);
			} 
			
			if (g.directed) {
				for (var k:String in g.V) {
					if (i == k) continue;
					w = g.V[k];
					
					// check if g is directed and if w is neighbour of v. If true, evaluate the force between v and w 
					// (w isn't a neighbour of v in g, but it is for our algorithm).
					if (w.isNeighbourOf(v)) {
						fx += (w.toX - v.toX);
						fy += (w.toY - v.toY);
					} 
				}
			}
		} else {
			cnt = 0;
		}
		
				
		forces[i] = {fx: fx, fy: fy};
		cnt ++;
	}
	
	for (i in g.V) {
		g.V[i].toX += Math.ceil(forces[i].fx*mf);
		g.V[i].toY += Math.ceil(forces[i].fy*mf);
	}
}