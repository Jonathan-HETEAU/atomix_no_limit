package atomixNoLimit.vue.component;

import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Rectangle;

import atomixNoLimit.model.atomixBaseClass.AtomixPartie;
import atomixNoLimit.vue.painter.AtomixPainter;

public class AtomixMoleculeComponent extends Component {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private AtomixPartie mModel ;
	private AtomixPainter mPainter ;
	
	private int[][] mMolecul ;
	
	private int mHeight ;
	private int mWidth ;
	
	private int mSize;
	private int mDecalH;
	private int mDecalW;
	
	
	
	
	public AtomixMoleculeComponent(AtomixPartie mModel, AtomixPainter mPainter) {
		super();
		this.mModel = mModel;
		this.mPainter = mPainter;
		setBackground(Color.GRAY);
		refresh();
	}

	@Override
	public void setBounds(Rectangle arg0) {
		super.setBounds(arg0);
		mesureCoponent();
	}
	
	@Override
	public void setBounds(int arg0, int arg1, int arg2, int arg3) {
		super.setBounds(arg0, arg1, arg2, arg3);
		mesureCoponent();
	}
	
	private void mesureCoponent()
	{
		mSize = Math.min(getWidth()/mWidth, getHeight()/mHeight);
		mDecalW = (getWidth() - (mWidth * mSize))/2;
		mDecalH =(getHeight() - (mHeight * mSize))/2;
		
	}
	
	public void refresh() {
		mHeight = mModel.getHeightMolecul();
		mWidth = mModel.getWidthMolecul();
		mMolecul = mModel.getMolecule();
		mesureCoponent();
	}
		
	
	public void paint(Graphics arg0) {
		
		for( int[] t : mMolecul ){
			mPainter.drawSol(getBackground(),getX() + mDecalW + (t[0] * mSize ) ,getY() + mDecalH + (t[1] * mSize), mSize );
			mPainter.drawAtome(t[2],false,getX() + mDecalW + (t[0] * mSize ),getY() + mDecalH + (t[1] * mSize), mSize );			
		}
	}
}
