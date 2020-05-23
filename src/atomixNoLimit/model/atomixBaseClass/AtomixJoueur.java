package atomixNoLimit.model.atomixBaseClass;

import java.io.Serializable;


public class AtomixJoueur  implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private long Niv = 1;
	private long mNiveau = 0;
				
	
	public AtomixJoueur(String chaine) {
		String[] split =chaine.split("\n");
		
		Niv = Long.valueOf(split[0]);
		mNiveau = Long.valueOf(split[1]);
	}
	
	public AtomixJoueur() {
		// TODO Auto-generated constructor stub
	}

	public void next() {
		Niv ++;
		mNiveau = 0;
	}
	public long getNiv() {
		return Niv;
	}
	
	public void setNivID(long id) {
		mNiveau = id;
	}
	public long getNivID() {
		return mNiveau ;
	}
	
	@Override
	public String toString() {
		// TODO Auto-generated method stub
		return ""+Niv+"\n"+mNiveau+"";
	}
}
