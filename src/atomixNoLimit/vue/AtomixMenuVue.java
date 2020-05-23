package atomixNoLimit.vue;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ComponentEvent;
import java.awt.event.ComponentListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.Random;

import javax.swing.JPanel;
import javax.swing.Timer;

import atomixNoLimit.controleur.AtomixControleur;
import atomixNoLimit.vue.component.AtomixMapComponent;
import atomixNoLimit.vue.layout.AtomixMenuLayout;
import atomixNoLimit.vue.painter.AtomixPainter;



public class AtomixMenuVue extends JPanel implements MouseListener , MouseMotionListener , ActionListener ,ComponentListener {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	
	private Rectangle[] mRectangle = new Rectangle[3];
	private boolean[] mRectangleSelect = new boolean[3];
	private String[] mTitre = {"Continuer ","Recommencer","Quitter "};
	private Timer mTimerRefresh ;
	private Timer mTimerMove ;

	private Rectangle mZone  = new Rectangle(-70, -70, 870, 670); 
	public  Random mRand = new Random();
	
	private Deco[] mDeco = new Deco[75];

	private int REFRESHSPEED = 25;
	private int MOVESPEED = 20;


	private AtomixPainter mPainter = new AtomixPainter();
	
	private  class Deco {
		
		private static final int  Vmax = 5;
		private static final int Vmax2 = 2 ;
		private static final int Vmax3 = Vmax2*2;
		
		public  Rectangle mZone =  null;
		public  Random mRand = null ;
		public int size ;
		public Color color; 
		public int x ;
		public int y;
		public int vX;
		public int vY;
		
		public Deco(Rectangle mZone, Random mRand ,Color color) {
			
			this.mZone = mZone;
			this.mRand = mRand;
			this.color = color;
			init();
		}
		
		public void move(){
			
			x += vX;
			y += vY;
			
			if( !mZone.contains(x, y)){
				init();
			}
		}
		
		private void init(){
			
			size = mRand.nextInt(50)+30;
			
			switch (mRand.nextInt(4)){
				case 0 :
					x=mZone.x;
					y=mZone.y + mRand.nextInt(mZone.height);
					vX = 1+mRand.nextInt(Vmax);
					vY = mRand.nextInt(Vmax3)-Vmax2;
					break;
				case 1 : 
					x=mZone.x + mZone.width;
					y=mZone.y + mRand.nextInt(mZone.height);
					vX = -1-mRand.nextInt(Vmax);
					vY = mRand.nextInt(Vmax3)-Vmax2;
					break;
				case 2 : 
					x=mZone.x + mRand.nextInt(mZone.width);
					y=mZone.y ;
					vX = mRand.nextInt(Vmax3)-Vmax2;
					vY = 1+mRand.nextInt(Vmax);
					break;
				case 3 : 
					x=mZone.x + mRand.nextInt(mZone.width);
					y=mZone.y +mZone.height;
					vX = mRand.nextInt(Vmax3)-Vmax2;
					vY = -1-mRand.nextInt(Vmax);
					break;
			}
			
			
		}
		
	}
	

	public AtomixMenuVue() {
		
		mRectangle[0]= new Rectangle();
		mRectangle[1]= new Rectangle();
		mRectangle[2]= new Rectangle();		
				
		
		for(int i =0 ; i <mDeco.length ; i++)
			mDeco[i]=new Deco(mZone,mRand,mPainter.generateurColor(mRand.nextInt(10)+1, 10) );
		
		mTimerRefresh = new Timer(REFRESHSPEED , this) ;
		mTimerMove = new Timer(MOVESPEED  , this) ;
		
                setLayout(new AtomixMenuLayout());
                add(new AtomixMapComponent());
                
		addComponentListener(this);
		addMouseListener(this);
		addMouseMotionListener(this);
		
	}
	
	
	public void stop(){
		mTimerMove.stop();
		mTimerRefresh.stop();
	}
	public void start(){
		mTimerMove.start();
		mTimerRefresh.start();
	}
	
	@Override
	public void mouseClicked(MouseEvent e) {
		
	
			if( mRectangleSelect[0]){
				mRectangleSelect[0]=false;
				AtomixControleur.getInstance().showMenu();
				
			}else if( mRectangleSelect[1]){
				mRectangleSelect[1]=false;
				AtomixControleur.getInstance().recommencerCampagne();
				AtomixControleur.getInstance().showPartie();
				
			}else if( mRectangleSelect[2]){
				mRectangleSelect[2]=false;
				AtomixControleur.getInstance().sauvegarder();	
				System.exit(0);
			}
			
		
	}

	@Override
	public void mouseEntered(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseExited(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mousePressed(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}
	
	public void moveDeco(){
		for(Deco d : mDeco)
			d.move();
	}
		
	@Override
	public void actionPerformed(ActionEvent e) {
		if( e.getSource() == mTimerMove){
			moveDeco();
		}
		else{
			if( e.getSource() == mTimerRefresh){
				repaint();
			}
		}
		
	}
	

	@Override
	public void componentHidden(ComponentEvent arg0) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void componentMoved(ComponentEvent arg0) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void componentResized(ComponentEvent arg0) {
		// TODO Auto-generated method stub
		mZone.setBounds(-75, -75, getWidth()+75, getHeight()+75);
		
		int mW = (int) (getWidth()*0.5) - 200;
		
	
		mRectangle[0].setBounds(mW,(int) (getHeight()*0.2),400 , 100);
		mRectangle[1].setBounds( mW,(int) (getHeight()*0.5),400 , 100);
		mRectangle[2].setBounds( mW,(int) (getHeight()*0.8),400 , 100);
		
	}


	@Override
	public void componentShown(ComponentEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	public void paint(Graphics g) {
		
		mPainter .setGraphics(g);
		g.setColor(Color.BLACK);
		g.fillRect(0, 0, getWidth(), getHeight());
				
		for(Deco d : mDeco)
			mPainter.drawAtome(d.color, d.x, d.y, d.size);
		
		for(int i  = 0 ; i <3 ; i++)
			mPainter.drawMenuButton(mRectangleSelect[i], mRectangle[i].x,mRectangle[i].y, mRectangle[i].width, mRectangle[i].height, mTitre[i]);
		
		
}


	@Override
	public void mouseDragged(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void mouseMoved(MouseEvent e) {

		for( int i = 0 ; i < 3 ; i++){
			if( mRectangle[i].contains(e.getPoint())){
				mRectangleSelect[i]=true;
			}
			else{
				mRectangleSelect[i]=false;
			}
		}
		
	}
	
}
