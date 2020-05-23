package atomixNoLimit.model.atomixBaseClass;



import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class AtomixNiveau  implements Serializable{
		
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public long Id = 0;
	public long Niv = 0;
	public boolean[][] Map= null;
	public List<int[]> Molecul=null; 
	public List<int[]> Atome =null;  
	public int Width = 0;
	public int Height= 0;
	
	public AtomixNiveau(String niv) {
		
		String[] split =niv.split("\n");
			
		Id = Long.valueOf(split[0]);
		Niv = Long.valueOf(split[1]);
		
		
		String[] taille = split[2].split(" ");
		Width = Long.valueOf(taille[0]).intValue();
		Height = Long.valueOf(taille[1]).intValue();
		
		Map = new boolean[Width][Height];
		int i = 0;
		
		
		char[] sMap = split[3].toCharArray();
		for( int y = 0 ; y < Height ; y++){
			for( int x = 0 ; x < Width ; x++){
				if( sMap[i] == '1')Map[x][y] = true;
				i++;
			}
		}
		
		i =0;
		Molecul = new ArrayList<int[]>();
		String[] sMolecul = split[4].split(" ");
		for(  int j = 0 ; j < sMolecul.length / 3 ; j++){
			int[] tmp = new int[3];
			for( int k = 0 ; k < 3 ; k++ ){
				tmp[k]= Integer.valueOf(sMolecul[i]).intValue();
				i++;
			}
			Molecul.add(tmp);
		}
		
		i =0;
		Atome = new ArrayList<int[]>();
		String[] sAtome = split[5].split(" ");
		for(  int j = 0 ; j < sAtome.length / 3 ; j++){
			int[] tmp = new int[3];
			for( int k = 0 ; k < 3 ; k++ ){
				tmp[k]= Integer.valueOf(sAtome[i]).intValue();
				i++;
			}
			Atome.add(tmp);
		}
		
	}	
	
	public AtomixNiveau() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public String toString() {
		String sMap = "";
		String sMolecul ="";
		String sAtome ="";
		for( int y = 0 ; y < Height ; y++){
			for( int x = 0 ; x < Width ; x++){
				if( Map[x][y]) {
					sMap += "1";
				}else{
					sMap += "0";
				}
			}
		}
		for(int[] m :Molecul ){
			sMolecul +=""+m[0]+" "+m[1]+" "+m[2]+" ";
		}
		for(int[] a :Atome ){
			sAtome +=""+a[0]+" "+a[1]+" "+a[2]+" ";
		}
		return "" + Id + "\n" + Niv + "\n" + Width + " " + Height + "\n"
				+ sMap + "\n" + sMolecul + "\n"
				+ sAtome +"";
	}	
	
}
