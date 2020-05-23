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
import atomixNoLimit.model.atomixBaseClass.AtomixPartie;
import atomixNoLimit.vue.component.AtomixMoleculeComponent;
import atomixNoLimit.vue.painter.AtomixPainter;

public class AtomixMoleculeVue extends JPanel implements ComponentListener , MouseListener, MouseWheelListener , MouseMotionListener{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private Rectangle mRectangle1 = new Rectangle();
	private Rectangle mRectangle2 = new Rectangle();
	private boolean mRectangle1Select = false;
	private boolean mRectangle2Select = false;
	
	private AtomixPartie mModel ;
	private int[][] mMolecul ;
	private AtomixCamera mCamera;
	private AtomixPainter mPainter;
	
	private int mHeight ;
	private int mWidth ;
	
	private int mSize ;
	private int mTailleW ;
	private int mTailleH ;
	

	private int mCenterH;
	private int mCenterW;

	private int mSizeTmp;
	private int mDecalH;
	private int mDecalW;
	
	private AtomixMoleculeComponent mMolecule ;
	
	public AtomixMoleculeVue(AtomixPartie partie) {
		// TODO Auto-generated constructor stub
		this.mModel = partie;
		mCamera = new AtomixCamera();
		mPainter = new AtomixPainter();
                refresh();
                
                mMolecule = new AtomixMoleculeComponent(mModel, mPainter);
                
                
		addMouseListener(this);
		addMouseMotionListener(this);
		addComponentListener(this);
		addMouseWheelListener(this);
	}
	
	
	
	public void mesure(){
		if(mTailleH != 0)mDecalH =(int)(mCenterH - ( (this.mTailleH* mCamera.y))/ mCamera.zoom);
		if(mTailleW != 0)mDecalW =(int)(mCenterW -( (this.mTailleW* mCamera.x))/ mCamera.zoom) ;
		mSizeTmp = (int) (this.mSize / mCamera.zoom ) ;
	}
			

	public void refresh() {
		
		mHeight = mModel.getHeightMolecul();
		mWidth = mModel.getWidthMolecul();
		mPainter.generateurColor(mModel.getNbrCouleur());
		mMolecul = mModel.getMolecule();
               // mMolecule.refresh();
		mesureCoponent();
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
	}
	
	@Override
	public void componentShown(ComponentEvent e) {
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public void mouseClicked(MouseEvent e) {
		if( e.getButton() == MouseEvent.BUTTON3){
			AtomixControleur.getInstance().switchVue();
		}
		if(e.getButton() == MouseEvent.BUTTON1){
			
			if(mRectangle1Select){
				AtomixControleur.getInstance().showMenu();
				mRectangle1.translate(-40,-40);
				mRectangle1Select =false;
			}
			if(mRectangle2Select){
				AtomixControleur.getInstance().showPartie();
				mRectangle2.translate(40, -40);
				mRectangle2Select =false;
			}
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
		
		Point p = e.getPoint();
		mCamera.position.setLocation(p);
		
		
	
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		
		
	}
	
	@Override
	public void mouseDragged(MouseEvent arg0) {
		Point p = arg0.getPoint();
		mCamera.move(p);
		repaint();
		
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
			if(!mRectangle2Select)mRectangle2.translate(-40, 40);
			mRectangle2Select = true;
			repaint();
		}else{
			if(mRectangle2Select){
				mRectangle2.translate(40,-40);
				repaint();
			}
			mRectangle2Select = false;
		}
	}

	@Override
	public void mouseWheelMoved(MouseWheelEvent e) {
		// TODO Auto-generated method stub
		if(e.getWheelRotation() == 1){
			mCamera.zoomMoins();
			repaint();
		}
		if(e.getWheelRotation() == -1){
			mCamera.zoomPlus();
			repaint();
		}
		
		System.out.println(e);
	}
	
	public void paint(Graphics g) {
		
		mPainter.setGraphics(g);
		
		g.setColor(Color.LIGHT_GRAY);
		g.fillRect(0, 0, getWidth(), getHeight());
		
		if( mCamera.update)
		{
			mesure();
			mCamera.update = false ;
		}		
		for( int[] t : mMolecul ){
			mPainter.drawAtome(t[2],false,mDecalW + (t[0] * mSizeTmp ), mDecalH + (t[1] * mSizeTmp ), mSizeTmp);			
		}
		if(mRectangle1Select){
			mPainter.drawButtonMenu(Color.green.brighter(), mRectangle1.x, mRectangle1.y,  (int)mRectangle1.getWidth());
		}else{
			mPainter.drawButtonMenu(Color.CYAN, mRectangle1.x, mRectangle1.y,  (int)mRectangle1.getWidth());
		}
		if(mRectangle2Select){
			mPainter.drawButtonMolecule(Color.green.brighter(), mRectangle2.x, mRectangle2.y, (int)mRectangle2.getWidth());
		}else{
			mPainter.drawButtonMolecule(Color.CYAN, mRectangle2.x, mRectangle2.y,  (int)mRectangle2.getWidth());
		}
		
	}

}
