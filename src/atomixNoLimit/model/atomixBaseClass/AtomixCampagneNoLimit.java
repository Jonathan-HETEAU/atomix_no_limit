package atomixNoLimit.model.atomixBaseClass;

import atomixNoLimit.model.atomixGenerateur.AtomixGenerateur;

public class AtomixCampagneNoLimit implements IAtomixCampagne{
	
	public static String PathFolder = "NoLimit";
	
	private IAtomixFile mFile ;
	
	private AtomixJoueur mJoueur ;
	private AtomixNiveau mNiveau = null;
	private AtomixSauvegarde mSave = null ;
	private AtomixGenerateur mGenerateur = new AtomixGenerateur();
	
	public AtomixCampagneNoLimit(IAtomixFile atomixFile) {
		mFile = atomixFile ;
		
		if(mFile.JoueurExiste()){
			mJoueur = mFile.JoueurRead();
		}else{
			mJoueur = new AtomixJoueur();
			mFile.JoueurCreate(mJoueur);
		}
		
		if( mJoueur.getNivID() == 0){
			mNiveau = mGenerateur.generateurNiveau(mJoueur.getNiv());
			mJoueur.setNivID(mNiveau.Id);
		}else{
			mNiveau = mFile.NiveauRead(mJoueur.getNivID());
		}
		
		
	}

	public AtomixNiveau getNiveau() {
		// TODO Auto-generated method stub
		return mNiveau;
	}

	public AtomixSauvegarde getSave() {
		// TODO Auto-generated method stub
		return mSave;
	}

	public AtomixJoueur getJoueur() {
		// TODO Auto-generated method stub
		return mJoueur;
	}

	public void next() {
		mJoueur.next();
		mNiveau = mGenerateur.generateurNiveau(mJoueur.getNiv());
		mSave = null;
		mJoueur.setNivID(mNiveau.Id);
	}
	
	public void sauvegarder(AtomixSauvegarde save){
		mSave = save ;
		mSave.Id = mNiveau.Id;
		mFile.SauvegardeUpdate(mSave);
		mFile.NiveauUpdate(mNiveau);
		mFile.JoueurUpdate(mJoueur);
	}

	@Override
	public boolean victoireCampagne() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean restart() {
		mFile.JoueurDelete();
		mFile.SauvegardeDelete();
		mJoueur = new AtomixJoueur();
		mNiveau = mGenerateur.generateurNiveau(mJoueur.getNiv());
		mJoueur.setNivID(mNiveau.Id); 
		return false;
	}
	
	
	
}
