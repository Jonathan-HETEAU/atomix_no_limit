package atomixNoLimit.vue;

import java.awt.Point;


public class AtomixCamera   {
	
	private static double m = 0.002;
	
	public double x = 0.50 ;
	public double y = 0.50;
	public double zoom = 1.00 ;
	public int width ;
	public int height;
	
	public Point position = new Point(0, 0);
	public boolean update ;
			
	public void zoomPlus(){
		zoom -= 0.01;
		if(zoom < 0.01)
		{
			zoom = 0.01;
		}
		update |= true;
	}
	public void zoomMoins(){
		zoom += 0.01;
		if(zoom > 1.00)
		{
			zoom = 1.00;
		}
		update |= true;
	}
	public void moveB(int m){
		y += (m *AtomixCamera.m* zoom );
		
		if(y >1.00)
		{
			y = 1.00;
		}
		update |= true;
	}
		
	public void moveH(int m){
		y -= (m*AtomixCamera.m * zoom );
		if(y < 0.00)
		{
			y = 0.00;
		}
		update |= true;
		
	}
	public void moveD(int m){
		x += (m *AtomixCamera.m* zoom );
		if(x > 1.00)
		{
			x = 1.00;
		}
		update |= true;
		
	}
	public void moveG(int m){
		x -= (m *AtomixCamera.m* zoom );
		if(x < 0.00)
		{
			x = 0.00;
		}
		update |= true;
		
	}

	public void move(Point p){
		if( p.x < position.x){
			moveD(position.x - p.x);
		}
		if( p.x >position.x){
			moveG(p.x-position.x);
		}
		if( p.y < position.y){
			moveB(position.y - p.y);
		}
		if( p.y > position.y){
			moveH(p.y -position.y);
		}
		position.setLocation(p);
	}
	
	
	
	
}
