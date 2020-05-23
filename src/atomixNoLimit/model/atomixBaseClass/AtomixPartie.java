package atomixNoLimit.model.atomixBaseClass;

import java.awt.Point;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;



public class AtomixPartie {
	
	
	public final static int S =0;
	public final static int N =1;
	public final static int E =2;
	public final static int O =3;
	public final static int Sols = -1 ;
	public final static int Murs = -2 ;
	private final static int[][] Rose = {{0,1},{0,-1},{1,0},{-1,0}};
	
	private AtomixNiveau mNiveau ;
	private int[] mAtomeRef = new int[3];
	private int[][] mMap ;
	
	private List<int[][]> mListeMove = new ArrayList<int[][]>()  ;
	private boolean mWin ;
	
	
	
	public AtomixPartie() {
		super();
	}
	
		
	public boolean moveAtome(int X , int Y ,int direction , int[] dest){
		boolean b = false;
		if( movePossible(X,Y ,direction) )
		{
			int x = X;
			int y = Y;
			while(mMap[x+ Rose[direction][0]][y + Rose[direction][1]] == -1)
			{
				x += Rose[direction][0];
				y += Rose[direction][1];
				b = true;
			}
			if(b)
			{
				int[][] tmp = new int[2][3]; 
				
				tmp[0][0]=X;
				tmp[0][1]=Y;
				tmp[0][2]=direction;
				tmp[1][0]=x;
				tmp[1][1]=y;
				
				mListeMove.add(tmp);
				
				mMap[x][y] = mMap[X][Y];
				mMap[X][Y] = -1;
				
				mAtomeRef[0] = x;
				mAtomeRef[1] = y;
				mAtomeRef[2] = mMap[x][y];
				
				if (dest != null)
					if ( dest.length == 2)
					{
						dest[0]=x;
						dest[1]=y;
					}
			
			}
			
		}
		return b ;
	}
	
	public boolean movePossible(int x, int y, int direction){
		
		boolean b = false;
		x += Rose[direction][0];
		y += Rose[direction][1];
		if( (direction >= 0) & (direction < 4))
		{
			if( isInMap(x,y) )
			{
				if(mMap[x][y] == Sols)
					return true;
			}
		}
		
		return b; 
	}
	
	public Point pointPlusDirection(Point p ,int direction , Point p1){
		
		p1.x = p.x + Rose[direction][0];
		p1.y = p.y + Rose[direction][1];
		
		return p1;
	}
	
	
	public boolean testMolecule (){
		int x , y ;
		boolean verif = false ;
		for ( int[] t : mNiveau.Molecul )
		{
			verif = true ;
			if (t[2] == mMap[mAtomeRef[0]][mAtomeRef[1]])
			{
				
				for ( int[] t2 : mNiveau.Molecul )
				{
					x = mAtomeRef[0]-t[0]+t2[0];
					y = mAtomeRef[1]-t[1]+t2[1];
					if( isInMap(x,y))
					{
						if(mMap[x][y] != t2[2])
							verif = false ;
					}
					else
					{
						verif = false ; 
					}
				}
			}
			else
			{
				verif = false ; 
			}
			mWin |= verif; 
		}
		
		 
		return verif;
	}
			
	public boolean isInMap(int x, int y){
		
		if( ( x >= 0) & (x < mNiveau.Width) )
			if( ( y >= 0) & (y < mNiveau.Height) )
				return true;
		return false;
	}


	public int getMapXY(int x, int y){
		if( isInMap(x,y) )
		{
			return mMap[x][y];
		}
		return Murs ;
	}
	
	public int getWidth(){
		return mNiveau.Width;
	}
	
	public int getHeight(){
		return mNiveau.Height;
	}
	
	public int getWidthMolecul(){
		
		int min = mNiveau.Width;
		int max = 0;
		for(int[] t : mNiveau.Molecul)
		{
			if( t[0] > max ) max = t[0] ;
			if( t[0] < min ) min = t[0] ;
		}
		
		return max - min +1;
		
	}
	public int getHeightMolecul(){
		int min = mNiveau.Height;
		int max = 0;
		for(int[] t : mNiveau.Molecul)
		{
			if( t[1] > max ) max = t[1] ;
			if( t[1] < min ) min = t[1] ;
		}
		
		return max - min +1;
	}
	public int[][] getMolecule (){
		int[][] molecul = new int[mNiveau.Molecul.size()][3];
		
		int i = 0;
		for(int[] t : mNiveau.Molecul)
		{
			molecul[i][0]=t[0];
			molecul[i][1]=t[1];
			molecul[i][2]=t[2];
			i++;
		}
		
		return molecul;	
	}
			
	public int[][] moveReturn(){
		int[][] tmp = null; 
		
		if(mListeMove.size() > 0 )
		{
			tmp = mListeMove.get(mListeMove.size()-1);
			
			mAtomeRef[0]=tmp[0][0];
			mAtomeRef[1]=tmp[0][1];
			
			mMap[tmp[0][0]][tmp[0][1]] = mMap[tmp[1][0]][tmp[1][1]];
			mMap[tmp[1][0]][tmp[1][1]] = Sols;
			mListeMove.remove(tmp);
			
			testMolecule ();
		}
		return tmp ;
	}
	
	public void restart(){
	 	mListeMove.clear();
	 	clearMap();	
	 	for( int[] a : mNiveau.Atome){
	 		mMap[a[0]][a[1]]=a[2];
	 	}
	 	mWin = false;
	}
	
		
	private void clearMap(){
		for( int x =0 ; x < mNiveau.Width ; x++ ){
			for( int y =0 ; y < mNiveau.Height ; y++){
				if( mMap[x][y] >= 0)
					mMap[x][y]= Sols;
			}
		}	
	}
	
	public boolean chargerPartie(AtomixNiveau niveau,AtomixSauvegarde save){
		
		if (niveau !=null)
			chargerNiveau( niveau );
		else
			return false;
		if (save !=null)
			chargerSauvegarde( save);
		else
			return false;
		
		
		return true;
	}
	
	public void chargerNiveau(AtomixNiveau niveau) {
		mListeMove.clear();
		mNiveau = niveau ;
		mMap = new int[mNiveau.Width][mNiveau.Height];
		
		for( int x =0 ; x < mNiveau.Width ; x++ ){
			for( int y =0 ; y < mNiveau.Height ; y++){
				if( mNiveau.Map[x][y])
					mMap[x][y] = Sols ;
				else
					mMap[x][y] = Murs ;
			}
		}
		for( int[] a : mNiveau.Atome){
	 		mMap[a[0]][a[1]]=a[2];
	 	}
	 	mWin = false;
	 }
	
	public void chargerSauvegarde(AtomixSauvegarde save){
		mListeMove.clear();
		for( int[][] m : save.mMoveList)
				mListeMove.add(m);
		
	 	clearMap();	
	 	for( int[] a : save.mAtomeList)
	 		mMap[a[0]][a[1]]=a[2];
	 	
	 	mWin = false;
	}
	
	
	
	public AtomixNiveau getNiveau() {
		return mNiveau;
	}
	
	public int getNbrCouleur(){
		long niv = mNiveau.Niv+1;
		int atome =  (int) Math.round(Math.sqrt(niv*2)) ;
		return (int)( (niv - (((atome) * (atome-1))/2)));
	}
	
	public AtomixSauvegarde getSauvegarde(){
		AtomixSauvegarde save = new AtomixSauvegarde();
		save.Id = mNiveau.Id;
		save.mMoveList = new int[mListeMove.size()][2][3];
		save.mAtomeList= new int[mNiveau.Molecul.size()][3];
		int i = 0 ;
		for( int[][] m : mListeMove)
		{
			save.mMoveList[i][0][0] = m[0][0];
			save.mMoveList[i][0][1] = m[0][1];
			save.mMoveList[i][0][2] = m[0][2];
			save.mMoveList[i][1][0] = m[1][0];
			save.mMoveList[i][1][1] = m[1][1];
			
			i++;
		}
		i = 0 ;
		for( int x =0 ; x < mNiveau.Width ; x++ ){
			for( int y =0 ; y < mNiveau.Height ; y++){
				if( mMap[x][y] >= 0){
					save.mAtomeList[i][0]=x;
					save.mAtomeList[i][1]=y;
					save.mAtomeList[i][2]=mMap[x][y];
					i++;
				}
			}
		}
		return save ;
	}
	
	public boolean isWin(){
		return mWin;
	}
	
	public int getNbrMove(){
		return mListeMove.size();
		
	}
	public Long getNiv(){
		return mNiveau.Niv;
	}
	


	@Override
	public String toString() {
		return "AtomixPartie [mNiveau=" + mNiveau + ", mScore=" + ", mAtomeRef=" + Arrays.toString(mAtomeRef) + ", mMap="
				+ Arrays.toString(mMap) + ", mListeMove=" + mListeMove
				+ ", mWin=" + mWin + "]";
	}
	
}
