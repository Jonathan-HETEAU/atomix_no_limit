package atomixNoLimit.model.atomixBaseClass;



public interface IAtomixCampagne {
	public AtomixNiveau getNiveau();
	public AtomixSauvegarde getSave();
	public AtomixJoueur getJoueur();
	public void next();
	public void sauvegarder(AtomixSauvegarde save);
	public boolean victoireCampagne();
	public boolean restart();
}
