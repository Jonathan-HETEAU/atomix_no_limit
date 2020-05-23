package atomixNoLimit.controleur;

import java.awt.Point;

import atomixNoLimit.model.atomixBaseClass.AtomixPartie;
import atomixNoLimit.vue.AtomixPartieVue;

public class AtomixPartieControleur {

	private AtomixPartieVue mVue;
	private AtomixPartie mModel;

	public Point mSelection = new Point();
	public Point[]  mDirection = new Point[4];
	
	public boolean isSelect = false ;
	public boolean[] isDirection = new boolean[4];
	
	private int[] mMove  = new int[2];
	
	public AtomixPartieControleur(AtomixPartieVue mVue,
			AtomixPartie mModel) {
		this.mVue = mVue ;
		this.mModel = mModel ;
		for(int i=0 ; i < 4 ; i++){
			mDirection[i]= new Point();
		}
	}
	
	public void selection(Point p){
		if( mModel.isInMap(p.x, p.y))
		{
			if( mModel.getMapXY(p.x, p.y) >= 0){
				mSelection.setLocation(p);
				isSelect = true;
				
				for(int i = 0 ; i < 4 ; i++ ){
					if( mModel.movePossible(p.x, p.y,i) )
					{
						mModel.pointPlusDirection(p, i, mDirection[i]);	
						isDirection[i]=true;
					}else{
						isDirection[i]=false;
					}
					
				}
				mVue.repaint();
			}else{
				if( isSelect ){
					for(int i = 0 ; i < 4 ; i++ ){
						if(isDirection[i]){
							if(p.equals(mDirection[i])){
								mModel.moveAtome(mSelection.x, mSelection.y,i,mMove);
								mModel.testMolecule ();
								isSelect = false;
								p.setLocation(mMove[0],mMove[1]);
								selection( p);
								mVue.repaint();
								if( mModel.isWin()){
								
									AtomixControleur.getInstance().nextPartie();
								}
							}
						}
					}
				}
			}
			
		}
	}
}
