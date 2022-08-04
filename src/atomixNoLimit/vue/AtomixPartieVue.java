package atomixNoLimit.vue;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.ComponentEvent;
import java.awt.event.ComponentListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;

import javax.swing.JPanel;

import atomixNoLimit.controleur.AtomixControleur;
import atomixNoLimit.controleur.AtomixPartieControleur;
import atomixNoLimit.model.atomixBaseClass.AtomixPartie;
import atomixNoLimit.vue.component.AtomixMoleculeComponent;
import atomixNoLimit.vue.painter.AtomixPainter;

public class AtomixPartieVue extends JPanel implements ComponentListener ,MouseWheelListener, MouseListener , MouseMotionListener{

	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private AtomixPartie mModel ;
	private AtomixPartieControleur mControleur;
	
	private AtomixCamera mCamera;
	private AtomixPainter mPainter;
	
	private Rectangle mRectangle1 = new Rectangle();
	private Rectangle mRectangle2 = new Rectangle();
	private Rectangle mRectangle3 = new Rectangle();
	private Rectangle mRectangle4 = new Rectangle();
	
	private boolean mRectangle1Select = false;
	private boolean mRectangle2Select = false;
	private boolean mRectangle3Select = false;
	private boolean mRectangle4Select = false;

	
	private int mHeight ;
	private int mWidth ;
	private int mNbrColor;
	
	private int mSize ;
	private int mTailleW ;
	private int mTailleH ;
	
	private int mCenterH;
	private int mCenterW;

	private int mSizeTmp;
	private int mDecalH;
	private int mDecalW;

	private AtomixMoleculeComponent mMoleculeComponent;

	

	public AtomixPartieVue(AtomixPartie mPartie) {
		// TODO Auto-generated constructor stub
		this.mModel = mPartie;
		this.mControleur = new AtomixPartieControleur(this, mPartie);
		mCamera = new AtomixCamera();
		mPainter = new AtomixPainter();
		
		mMoleculeComponent = new AtomixMoleculeComponent(mPartie, mPainter); 
		
		refresh();
		addMouseListener(this);
		addMouseMotionListener(this);
		addComponentListener(this);
		addMouseWheelListener(this);
	}

	private Point selection(Point p) {
		p.x =( p.x - mDecalW ) / mSizeTmp;
		p.y =( p.y - mDecalH ) / mSizeTmp;				
		return p;		
	}
	public void mesure(){
		
		mDecalH =(int)(mCenterH - ( (this.mTailleH* mCamera.y))/ mCamera.zoom);
		mDecalW =(int)(mCenterW -( (this.mTailleW* mCamera.x))/ mCamera.zoom) ;
		mSizeTmp = (int) (this.mSize / mCamera.zoom ) ;
	}
	
	public void mesureCoponent()
	{
		int w = getWidth();                                                                                
		int h = getHeight();
		mCenterH = (h/2) ;
		mCenterW = (w/2) ;
		mSize = Math.min(w/mWidth, h/mHeight);
		mTailleW = mWidth * mSize;
		mTailleH = mHeight * mSize;
		mRectangle1.setBounds(-60,-60,100 , 100);
		mRectangle2.setBounds( w -40 ,-60,100 , 100);
		mMoleculeComponent.setBounds( mRectangle2);
		mRectangle3.setBounds( mCenterW-75 ,25,50 , 50);
		mRectangle4.setBounds( mCenterW+25 ,25,50 , 50);
		
	}
	
	public void refresh() {
		
		mHeight = this.mModel.getHeight();
		mWidth = this.mModel.getWidth();
		mNbrColor = this.mModel.getNbrCouleur();
		mesureCoponent();
		mControleur.isSelect=false;
		if( mTailleH != 0 & mTailleW != 0)
			mesure();
		repaint();
	}

	
	
	@Override
	public void componentHidden(ComponentEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void componentMoved(ComponentEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void componentResized(ComponentEvent e) {
		// TODO Auto-generated method stub
		mesureCoponent();
		mesure();
		
	}
	
	@Override
	public void componentShown(ComponentEvent e) {
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public void mouseClicked(MouseEvent e) {
		// TODO Auto-generated method stub
				
		if(e.getButton() == MouseEvent.BUTTON1){
			
			if(mRectangle1Select){
				AtomixControleur.getInstance().showMenu();
				mRectangle1.translate(-40, -40);
				mRectangle1Select =false;
			}
			if(mRectangle2Select){
				AtomixControleur.getInstance().showMolecule();
				mRectangle2.translate(40, -40);
				mMoleculeComponent.setBounds(mRectangle2);
				mRectangle2Select =false;
			}
			if(mRectangle3Select){
				AtomixControleur.getInstance().selectBack();
				
			}
			if(mRectangle4Select){
				AtomixControleur.getInstance().recommencerNiveau();
				
			}
		}
		
		if( e.getButton() == MouseEvent.BUTTON3){
			AtomixControleur.getInstance().switchVue();
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
		if(e.getButton() == MouseEvent.BUTTON1){
			Point p = selection(e.getPoint());
			mControleur.selection(p);
		}
		Point p = e.getPoint();
		mCamera.position.setLocation(p);
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		
	}
	
	@Override
	public void mouseDragged(MouseEvent arg0) {
		Point p = arg0.getPoint();
		if( arg0.getModifiersEx() == MouseEvent.BUTTON3_DOWN_MASK){
			mCamera.move(p);
			repaint();
		}
	}

	@Override
	public void mouseMoved(MouseEvent e) {
		// TODO Auto-generated method stub
		
		
		Point p = e.getPoint();
		
		if(mRectangle1.contains(p)){
			if(!mRectangle1Select)mRectangle1.translate(40, 40);
			
			mRectangle1Select = true;
			repaint();
		}else{
			if(mRectangle1Select){
				mRectangle1.translate(-40,-40);
				repaint();
			}
			mRectangle1Select = false;
		}
		if(mRectangle2.contains(p)){
			if(!mRectangle2Select){
				mRectangle2.translate(-40, 40);
				mMoleculeComponent.setBounds(mRectangle2);
			}
			mRectangle2Select = true;
			repaint();
		}else{
			if(mRectangle2Select){
				mRectangle2.translate(40,-40);
				mMoleculeComponent.setBounds(mRectangle2);
				repaint();
			}
			mRectangle2Select = false;
		}
		if(mRectangle3.contains(p)){
			mRectangle3Select = true;
			repaint();
		}else{
			if(mRectangle3Select)repaint();
			mRectangle3Select = false;
		}
		if(mRectangle4.contains(p)){
			mRectangle4Select = true;
			repaint();
		}else{
			if(mRectangle4Select)repaint();
			mRectangle4Select = false;
		}
	}
	
	@Override
	public void mouseWheelMoved(MouseWheelEvent e) {
		if(e.getWheelRotation() == 1){
			mCamera.zoomMoins();
			repaint();
		}
		if(e.getWheelRotation() == -1){
			mCamera.zoomPlus();
			repaint();
		}
	}
	
	
	@Override
	public void paint(Graphics g) {
		
		//System.out.println("REPAINT  "+mNbrColor);		
		mPainter.setGraphics(g);
		mPainter.generateurColor(mNbrColor);
		g.setColor(Color.BLACK);
		g.fillRect(0, 0, getWidth(), getHeight());
		
		if( mCamera.update)
		{
			mesure();
			mCamera.update = false ;
		}
		for( int x = 0 ; x < this.mWidth ; x++ )
		{
			for( int y = 0 ; y < this.mHeight ; y++)
			{
				int tmp = mModel.getMapXY(x, y);
				
				if( tmp > AtomixPartie.Murs){
					mPainter.drawSol(Color.LIGHT_GRAY , mDecalW + (x * mSizeTmp ), mDecalH + (y * mSizeTmp ), mSizeTmp);
					if( tmp > AtomixPartie.Sols){
						//mPainter.drawAtome(mPainter.generateurColor(tmp, mNbrColor),mDecalW + (x * mSizeTmp ), mDecalH + (y * mSizeTmp ), mSizeTmp);
						mPainter.drawAtome(tmp,false, mDecalW + (x * mSizeTmp ), mDecalH + (y * mSizeTmp ), mSizeTmp);
					}
				}else
                                {
                                   // mPainter.drawMur(0 , mDecalW + (x * mSizeTmp ), mDecalH + (y * mSizeTmp ), mSizeTmp);
                                }
								
			}
		}
		if( mControleur.isSelect){
			for(int i = 0 ; i < 4 ; i++){
				if( mControleur.isDirection[i]){
					mPainter.drawFleche(Color.green, mDecalW + (mControleur.mDirection[i].x * mSizeTmp ), mDecalH + (mControleur.mDirection[i].y * mSizeTmp ), mSizeTmp, i);
				}
			}
		}
		
		//mPainter.drawNiveau(Color.green,mCenterW, 0, mModel.getNiv());
		mPainter.drawNiveau( mModel.getNiv(), mCenterW, 0, 50);
		if(mRectangle1Select){
			mPainter.drawButtonMenu(Color.green.brighter(), mRectangle1.x, mRectangle1.y,  (int)mRectangle1.getWidth());
		}else{
			mPainter.drawButtonMenu(Color.CYAN, mRectangle1.x, mRectangle1.y,  (int)mRectangle1.getWidth());
		}
		if(mRectangle2Select){
			//mMoleculeComponent.paint(g);
			mPainter.drawButtonMolecule(Color.green.brighter(), mRectangle2.x, mRectangle2.y, (int)mRectangle2.getWidth());
		}else{
			mPainter.drawButtonMolecule(Color.CYAN, mRectangle2.x, mRectangle2.y,  (int)mRectangle2.getWidth());
		}
		if(mRectangle3Select){
			mPainter.drawButtonBack(Color.green.brighter(), mRectangle3.x, mRectangle3.y,  (int)mRectangle3.getWidth());
		}else{
			mPainter.drawButtonBack(Color.CYAN, mRectangle3.x, mRectangle3.y,  (int)mRectangle3.getWidth());
		}
		if(mRectangle4Select){
			mPainter.drawButtonRestart(Color.green.brighter(), mRectangle4.x, mRectangle4.y, (int)mRectangle4.getWidth());
		}else{
			mPainter.drawButtonRestart(Color.cyan, mRectangle4.x, mRectangle4.y, (int)mRectangle4.getWidth());
		}
		
		
		
	}
}
