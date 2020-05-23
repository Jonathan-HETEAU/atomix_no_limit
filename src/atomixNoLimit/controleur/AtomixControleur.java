package atomixNoLimit.controleur;

import atomixNoLimit.model.atomixBaseClass.AtomixCampagneNoLimit;
import atomixNoLimit.model.atomixBaseClass.AtomixFile;
import atomixNoLimit.model.atomixBaseClass.AtomixPartie;
import atomixNoLimit.model.atomixBaseClass.IAtomixCampagne;
import atomixNoLimit.vue.AtomixMenuVue;
import atomixNoLimit.vue.AtomixMoleculeVue;
import atomixNoLimit.vue.AtomixPartieVue;
import atomixNoLimit.vue.AtomixVue;

public class AtomixControleur {

	private static AtomixControleur mInstance ;
	
	public static synchronized AtomixControleur getInstance(){
		
		if( mInstance == null){
			mInstance = new AtomixControleur();
		}
		return mInstance;
	}
	
	private static final String PARTIE= "Partie";
	private static final String MOLECULE= "Molecule";
	private static final String MENU= "Menu";
	
	private AtomixVue mVue ;
	private AtomixMenuVue mMenuVue ;
	private AtomixPartieVue mPartieVue ;
	private AtomixMoleculeVue mMoleculVue ;
	
	private IAtomixCampagne mCampagne ;	
	private AtomixPartie mPartie ;
	private String  mShow = null;
	private String  mShow2= null;
	
	
	
	
	private AtomixControleur() {
		
		this.mPartie = new AtomixPartie();
		
		runCampagne(AtomixCampagneNoLimit.PathFolder);
		
		this.mMenuVue = new AtomixMenuVue(); 
		this.mPartieVue = new AtomixPartieVue(this.mPartie );
		this.mMoleculVue = new AtomixMoleculeVue(this.mPartie);
		this.mVue = new AtomixVue(this ,this.mMenuVue,this.mPartieVue,this.mMoleculVue);
				
		mShow = PARTIE;
		showMenu();
	}
	
	

	public void showPartie() {
		mVue.show(PARTIE);
		mShow = PARTIE ;
		
	}
	public void showMolecule() {
		mVue.show(MOLECULE);
		mShow = MOLECULE ;
		
	}
	public void showMenu() {
		if( mShow.equals(MENU)){
			if( mShow2 != null)
			{
				mVue.show(mShow2);
				mShow = mShow2;
				mMenuVue.stop();
			}
		}else{
			 mShow2 = mShow ;
			 mVue.show(MENU);
			 mShow = MENU;
			 mMenuVue.start();
		}
		
		
	}
	
	public void runCampagne(String campagne){
		if(mCampagne != null){
			mCampagne.sauvegarder(mPartie.getSauvegarde());
		}
		
		if(campagne.equals(AtomixCampagneNoLimit.PathFolder) ){
			this.mCampagne = new AtomixCampagneNoLimit(new AtomixFile(AtomixCampagneNoLimit.PathFolder));
		}
		this.mPartie.chargerPartie(mCampagne.getNiveau(), mCampagne.getSave());
	}
	
	public void runCampagneClassique(){
		
	}
	
	public void switchVue(){
		
		if ( mShow.equals(PARTIE)){
			showMolecule();
		}
		else if ( mShow.equals(MOLECULE)) {
			showPartie();
		}
		
		
	}
	
	public void selectBack(){
		mPartie.moveReturn();
		mPartieVue.refresh();
	}
	
	public void recommencerNiveau(){
		mPartie.restart();
		mPartieVue.refresh();
	}
	
	public void recommencerCampagne(){
		mCampagne.restart();
		mPartie.chargerNiveau(mCampagne.getNiveau());
		mPartieVue.refresh();
		mMoleculVue.refresh();
	}
	
	
	public  void nextPartie() {
		mCampagne.next();
		mPartie.chargerNiveau(mCampagne.getNiveau());
		mPartieVue.refresh();
		mMoleculVue.refresh();
	}

	public void sauvegarder(){
		mCampagne.sauvegarder(mPartie.getSauvegarde());
	}
	
	public static void main(String[] args){
		// TODO Auto-generated method stub
		AtomixControleur.getInstance();
	}	
}
