package atomixNoLimit.vue.painter;


import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;



public class AtomixPainter {

	class AtomeSize {
		int size;
		int size2;
		int decal;
	}
	
	class ButtonMenuSize  {
		int height ;
		int width ;
		int height2 ;
		int width2 ;
		int decal ;
		Font font ;
	}
	
	class NiveauSize {
		int niv ;
		int height ;
		int size ;
		Font font ;
		String texte ;
	}
	
	
	
	private Graphics g;
		
	private Color[][] buttonColor = new Color[2][2];
	private ButtonMenuSize buttonMenuSize = new ButtonMenuSize();
	private NiveauSize niveauSize = new NiveauSize();
	
	
	private Color[][] atomeColor = new Color[0][0];
	private AtomeSize atomeSize = new AtomeSize();
	
	
	
		
	public AtomixPainter() {
		
		
		buttonColor[1][1]= Color.CYAN;
                buttonColor[1][0]= buttonColor[1][1].darker();
		
		buttonColor[0][1]= new Color(0,255,255,100);
		buttonColor[0][0]= buttonColor[0][1].darker();
		          
	}
	
	
	public void setGraphics(Graphics g){
		this.g = g ;
	}
	
	public void generateurColor(int nbr ){
		
		if( atomeColor.length != nbr){
			
			atomeColor = new Color[nbr][3];
									
			for( int i = 0 ; i < nbr ; i++){
				atomeColor[i][0]= new Color((i*28)%255,(i*100)%255,(i*40)%255);
				atomeColor[i][1]= atomeColor[i][0].brighter()  ;
				atomeColor[i][2]= atomeColor[i][1].brighter()  ;
			}
		}
	}
	
	public void drawAtome(int num ,boolean select , int x , int y , int size ){
		
		if( atomeSize.size != size){
			atomeSize.size = size ;
			atomeSize.decal = (int) (size*0.05);
			atomeSize.size2 = size - ( 2* atomeSize.decal);
		}
		
		short i =0 ;
		
		if( select) i = 1;
		
		g.setColor(atomeColor[num][i]);
		g.fillOval(x,y,atomeSize.size,atomeSize.size);
		g.setColor(atomeColor[num][i+1]);
		g.fillOval(x+atomeSize.decal,y+atomeSize.decal,atomeSize.size2,atomeSize.size2);
	}
	

	public void drawAtome(Color color , int x , int y , int size ){
		g.setColor(color.darker());
		g.fillOval(x,y,size,size);
		g.setColor(color);
		int decal = (int) (size*0.05);
		size = size - ( 2* decal);
		g.fillOval(x+decal,y+decal,size,size);
	}
	
	public void drawSol(Color color , int x , int y , int size){
		g.setColor( buttonColor[1][0]);
		g.fillRect(x, y, size, size);
		
	}
	
	public void drawMur(int type,int x , int y , int size){
		g.setColor( buttonColor[0][1]);
		g.fillRoundRect(x, y, size, size,12,12);
	}
	
	public void drawMenuButton(boolean select ,int x , int y , int width , int height ,String texte){
		
		if( (buttonMenuSize.height != height) | (buttonMenuSize.width != width) ){
			buttonMenuSize.height = height ;
			buttonMenuSize.width = width ;
			buttonMenuSize.decal =(int) (Math.min(height, width)*0.1);
			buttonMenuSize.height2 = buttonMenuSize.height -(buttonMenuSize.decal *2);
			buttonMenuSize.width2 = buttonMenuSize.width -(buttonMenuSize.decal *2);
		}
		
		short i =0 ;
		
		if( select) i = 1;
		
		g.setColor(buttonColor[i][0]);
		g.fillRoundRect(x, y, width, height, 90, 90);
		g.setColor(buttonColor[i][1]);
		g.fillRoundRect(x+ buttonMenuSize.decal , y+ buttonMenuSize.decal , buttonMenuSize.width2 , buttonMenuSize.height2, 90, 90);
		g.setColor(buttonColor[i][0]);
		g.setFont(new Font("Dialog", Font.BOLD,buttonMenuSize.height2 - (buttonMenuSize.decal *4) ));
		FontMetrics fm = g.getFontMetrics();
		g.drawString(texte, x+ (int)(buttonMenuSize.width *0.50)- fm.stringWidth(texte)/2, y+ buttonMenuSize.height - (buttonMenuSize.decal *4) );
	}
	
	
	public void drawNiveau(long niv,int x , int y,int height){
		
		if( niveauSize.niv != niv){
			niveauSize.texte =Long.toString(niv);
		}
		
		
		if( height != niveauSize.height ){
			
			niveauSize.height = height;
			niveauSize.font = new Font("Dialog", Font.BOLD,height);
					
		}
		
		
		
		g.setFont(niveauSize.font);
		
		FontMetrics fm = g.getFontMetrics();
				
		int width = fm.stringWidth(niveauSize.texte);
				
		x -= width/2;
		y -= height/2;  
		
		g.setColor(buttonColor[1][0]);
		g.fillRoundRect(x-(int)(width *0.30), y-(int)(height *0.30), width+ (int)(width *0.60), height+ (int)(height *0.60), 25, 25);
		g.setColor(buttonColor[1][1]);
		g.fillRoundRect(x-(int)(width *0.20), y- (int)(height *0.20),width+ (int)(width *0.40), height+ (int)(height *0.40), 25, 25);
		g.setColor(buttonColor[1][0]);
		g.drawString(niveauSize.texte, x, (int) (y+ (height*1.1)));
	}
	
	
	
	
	
	public void drawFleche(Color color,int x , int y , int size,int type  ){
		short[] drawFleche ={55,235,145,325};
		g.setColor(color);
		g.fillArc(x , y, size, size, drawFleche[type] , 70);
		g.setColor(color.darker());
		g.fillArc(x , y, size,size, drawFleche[type] + 15 ,40);
	}

	public void drawButtonMenu(Color color,int x , int y , int size){
			drawAtome( color ,  x ,  y ,  size );
			g.setColor(color.darker());
			
			g.fillRect(x+ (int)(size *0.33),y+ (int)(size *0.33),(int)(size *0.33),(int)(size *0.33));
	}
		

	public void drawButtonMolecule(Color color, int x, int y, int size) {
		// TODO Auto-generated method stub
		drawAtome( color ,  x ,  y ,  size );
		g.setColor(color.darker());
		g.fillOval((int) (  x+size*0.20 ), (int) ( y+size*0.40 ),(int) (  size*0.20 ),(int) (  size*0.20 ));
		g.fillOval((int) (  x+size*0.40 ), (int) ( y+size*0.40 ),(int) (  size*0.20 ),(int) (  size*0.20 ));
		g.fillOval((int) (  x+size*0.60 ), (int) ( y+size*0.40 ),(int) (  size*0.20 ),(int) (  size*0.20 ));
	}

	public void drawButtonBack(Color color, int x, int y, int size) {
		drawAtome( color ,  x ,  y ,  size );
		g.setColor(color.darker());
		g.fillArc((int) (x -(size*0.25)) , y ,  size, size, 315 ,90);
		
	}

	public void drawButtonRestart(Color color, int x, int y, int size) {
		// TODO Auto-generated method stub
		drawAtome( color ,  x ,  y ,  size );
		g.setColor(color.darker());
		g.fillOval((int) (  x+size*0.15 ), (int) ( y+size*0.15 ),(int) (  size*0.70 ),(int) (  size*0.70 ));
		g.setColor(color);
		g.fillOval((int) (  x+size*0.25 ), (int) ( y+size*0.15 ),(int) (  size*0.50 ),(int) (  size*0.50 ));
		g.setColor(color.darker());
		g.fillArc(x ,(int) ( y-size*0.25 ), (int) (  size*0.80 ),(int) (  size*0.80 ), 300 ,60);
		
	}
	
	public Color generateurColor( int num , int nbr){
		return  new Color((num*28)%255,(num*100)%255,(num*40)%255 );
                
	}

}
