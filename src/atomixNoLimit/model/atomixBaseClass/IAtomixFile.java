package atomixNoLimit.model.atomixBaseClass;

public interface IAtomixFile {

	public boolean JoueurExiste();
	public boolean JoueurDelete();
	public AtomixJoueur JoueurRead();
	public boolean JoueurCreate( AtomixJoueur joueur);
	public boolean JoueurUpdate( AtomixJoueur joueur );
	
	public boolean NiveauExiste(long id);
	public boolean NiveauDelete( long id);	
	public AtomixNiveau NiveauRead( long id);
	public boolean NiveauCreate( AtomixNiveau niveau);
	public boolean NiveauUpdate( AtomixNiveau niveau );
	
	public boolean SauvegardeExiste();
	public boolean SauvegardeDelete();
	public AtomixSauvegarde SauvegardeRead();
	public boolean SauvegardeCreate( AtomixSauvegarde save);
	public boolean SauvegardeUpdate( AtomixSauvegarde save );
	
	
}
