package atomixNoLimit.model.atomixBaseClass;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;



public class AtomixFile implements IAtomixFile {

	private static String PathNiveau="Niveau";
	private static String PathJoueur="Joueur";
	private static String PathSauvegarde="Sauvegarde";
	
	public String mRacine ;
	public String mNiveau="Niveau";
	public String mJoueur="Joueur";
	public String mSauvegarde="Sauvegarde";
	
	public AtomixFile(String racine){
		
		mRacine = racine ;
		mNiveau = mRacine+File.separator+PathNiveau ;
		mJoueur = mRacine+File.separator+PathJoueur+".j";
		mSauvegarde = mRacine+File.separator+PathSauvegarde+".s" ;
		File f = new File(mRacine);
		if (!f.exists())
		{
			f.mkdir();
		}
		f = new File(mNiveau);
		if (!f.exists())
		{
			f.mkdir();
		}
	}
	@Override
	public boolean JoueurExiste() {
		File f = new File(mJoueur);
		return f.exists();
	}


	@Override
	public boolean JoueurDelete() {
		if( JoueurExiste()){
			File f = new File(mJoueur);
			f.delete();
			return true;
		}
		return false;
	}


	@Override
	public AtomixJoueur JoueurRead() {
		
		if( JoueurExiste()){
			try{
				String tmp = readFile(mJoueur);
				if( tmp != null){
					AtomixJoueur j = new AtomixJoueur(tmp);
					return j;
				}
			}		
			catch (Exception e){
				System.out.println(e.toString());
			}
		}
		
		return null;
	}


	@Override
	public boolean JoueurCreate(AtomixJoueur joueur) {
	
		return JoueurUpdate(joueur);
		
	}


	@Override
	public boolean JoueurUpdate(AtomixJoueur joueur) {
		return writeFile(mJoueur, joueur.toString());
	}


	@Override
	public boolean NiveauExiste(long id) {
		File f = new File(mNiveau+File.separator+id+".niv");
		return f.exists();
	}


	@Override
	public boolean NiveauDelete(long id) {
		if( NiveauExiste( id)){
			File f = new File(mNiveau+File.separator+id+".niv");
			f.delete();
			return true;
		}
		return false;
	}


	@Override
	public AtomixNiveau NiveauRead(long id) {
		
		if( NiveauExiste(id)){
			try{
				String tmp = readFile(mNiveau+File.separator+id+".niv");
				if( tmp != null){
					AtomixNiveau n = new AtomixNiveau(tmp);
					return n;
				}
				
			}		
			catch (Exception e){
				System.out.println(e.toString());
			}
		}
		
		return null;
	}


	@Override
	public boolean NiveauCreate(AtomixNiveau niveau) {
		// TODO Auto-generated method stub
		return NiveauUpdate( niveau);
	}


	@Override
	public boolean NiveauUpdate(AtomixNiveau niveau) {
		return writeFile(mNiveau+File.separator+niveau.Id+".niv", niveau.toString());
	}

	@Override
	public boolean SauvegardeCreate(AtomixSauvegarde save) {
		// TODO Auto-generated method stub
		return false;
	}


	@Override
	public boolean SauvegardeUpdate(AtomixSauvegarde save) {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public boolean SauvegardeExiste() {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public boolean SauvegardeDelete() {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public AtomixSauvegarde SauvegardeRead() {
		// TODO Auto-generated method stub
		return null;
	}
	
	private String readFile(String path){
		try{
			File f = new File(path);
			String chaine = "";
			InputStream ips=new FileInputStream(f); 
			InputStreamReader ipsr=new InputStreamReader(ips);
			BufferedReader br=new BufferedReader(ipsr);
			String ligne;
			while ((ligne=br.readLine())!=null){
				chaine+=ligne+"\n";
			}
			br.close(); 
			return chaine;
		}		
		catch (Exception e){
			System.out.println(e.toString());
		}
		return null;
	}
	
	private boolean writeFile(String path , String chaine){
		try {
			File f = new File(path);
			FileWriter fw = new FileWriter (f);
			BufferedWriter bw = new BufferedWriter (fw);
			PrintWriter fichierSortie = new PrintWriter (bw); 
				fichierSortie.println (chaine); 
			fichierSortie.close();
			return true;
		}
		catch (Exception e){
			System.out.println(e.toString());
		}	
		return false;
	}
	
}
