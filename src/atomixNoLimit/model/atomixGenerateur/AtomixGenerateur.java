package atomixNoLimit.model.atomixGenerateur;




import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Random;



import atomixNoLimit.model.atomixBaseClass.AtomixNiveau;

public class AtomixGenerateur {

	private AtomixNiveau mNiveau ;
	private int mNbrAtome ;
	private int mNbrCouleur ;
	private int mNbrMouvement ;
	private List<int[]> mListAtome ;
	private List<int[]> mListMolecul ;
	private int x, y ;
	private Random mRandom;
	
	private void generateurValeur(){
		
		long niv = mNiveau.Niv+1;
		mNbrAtome =  (int) Math.round(Math.sqrt(niv*2)) ;
		mNbrCouleur =(int)( (niv - (((mNbrAtome) * (mNbrAtome-1))/2)));
		mNbrMouvement= mNbrAtome * 10 ;
				
		y = (int) Math.sqrt(( mNbrAtome / 3 ) + 1);
		x = y ;
		if ( (x * y) < (( mNbrAtome / 3 ) + 1) )
			x ++;
		
		
	}
	private void generateurMap(){
		
		int base , tmp ;
					
		int[] NO = {35,98,2240,6272,2114,224};
		int[] NE = {536,776,896,8456,8576,12416};
		int[] SO = {2164736,137216,198656,2195456,3178496,229376};
		int[] SE = {143360,401408,917504,9175040,25690112,8658944};
		int[] R = { 33554431,33554431,33554431,33554431,33554431,33554431};
		mNiveau.Map= new boolean [(x*5)+2][(y*5)+2];
		mNiveau.Width = (x *5)+2;
		mNiveau.Height= (y *5)+2;
		
		for ( int i= 0 ; i < x ; i ++)
		{
			for ( int j= 0 ; j < y ; j ++)
			{
				tmp = mRandom.nextInt(6);
				R[tmp]=0;
				base = 4211716;
				base = base | (NO[mRandom.nextInt(6)] & R[0]);	
				base = base | (NE[mRandom.nextInt(6)] & R[1]);	   
				base = base | (SO[mRandom.nextInt(6)] & R[2]);		   
				base = base | (SE[mRandom.nextInt(6)] & R[3]);	
				base = base | ( mRandom.nextInt(33554432 )&  R[4]); 
				R[tmp]=33554431;
				tmp = base ;
				
				for(  int k = 1 ; k < 6 ;k ++)
					for( int l=1; l < 6 ; l ++)
					{
						if ( tmp % 2 == 0)
							mNiveau.Map[(i*5)+l][(j*5) + k]=false;
						else
							mNiveau.Map[(i*5)+l][(j*5) + k]=true;
						tmp = tmp >> 1;
					}
			}
		}	
				
	}
	
	private void generateGraine(int[] tab){
		int[][] pos = {{0,2},{2,0},{2,4},{4,2}};
		int tmp = mRandom.nextInt(4) ;
		
		
		tab[0] = (mRandom.nextInt(x)*5)+1+ pos[tmp][0];
		tab[1] = (mRandom.nextInt(y)*5)+1+ pos[tmp][1];
		tab[2]= 0;
	}
	
	
	
	private void generateurMolecule(){
		
		List<int[]> listVide = new ArrayList<int[]>();
		int[][] pos = {{-1,0},{1,0},{0,-1},{0,1}};
		int[] tab = new int[3] ;
		int[] tmp = new int[2] ;
		int[] tmp2;
		int[] min = new int[2];
		
		
		generateGraine(tab);
	
		mNiveau.Map[tab[0]][tab[1]]= false ;
		mListAtome.add(tab);
		min[0] = tab[0];
		min[1] = tab[1];
		
		
		for( int i = 1 ; i < mNbrAtome ; i++)
		{
			
			for(int[] t : pos)
			{
				tmp[0]= tab[0]+t[0];
				tmp[1]= tab[1]+t[1];
				
				if ( mNiveau.Map[tmp[0]][tmp[1]])
				{
					mNiveau.Map[tmp[0]][tmp[1]]= false;
					listVide.add(tmp);
					tmp = new int[2] ;
				}
			}
			tmp2 = 	listVide.get(mRandom.nextInt(listVide.size()));		
			tab = new int[3] ;
			tab[0] = tmp2[0];
			if ( tmp2[0] < min[0] ) min[0]=tmp2[0] ;
			tab[1] = tmp2[1];		
			if ( tmp2[1] < min[1] ) min[1]=tmp2[1] ;
			tab[2] = i % mNbrCouleur ; 
			
			listVide.remove(tmp2);
			
			mListAtome.add(tab);
		}
		
		for(int[] t : listVide )
		{
			
			mNiveau.Map[t[0]][t[1]]= true;
		}
		
		for(int[] t : mListAtome )
		{
			tab = new int[3] ;
			tab[0]=t[0]-min[0];
			tab[1]=t[1]-min[1];
			tab[2]=t[2];
			mListMolecul.add(tab);
		}
		
		listVide.clear();
	}
	
	
	
	private void generateurPuzzle(){
		
		List<int[]> listVide = new ArrayList<int[]>();
		int[][] pos = {{-1,0},{1,0},{0,-1},{0,1}};
		int[] tab = new int[3] ;
		int[] tmp ;
		int[] tmp2 = new int[2] ;
		int nbr =0 ;
		int security = 0 ;
		long i = 0 ;
		
		while ( nbr < mNbrMouvement)
		{
			tab = mListAtome.get((int) (i % mListAtome.size()));
			for(int[] t : pos)
			{
				if ( mNiveau.Map[tab[0]+t[0]][tab[1]+t[1]] & ! mNiveau.Map[tab[0]-t[0]][tab[1]-t[1]])
				{
					listVide.add(t);
				}
			}
			if( listVide.size() > 0)
			{
				mNiveau.Map[tab[0]][tab[1]]= true;
				tmp = listVide.get(mRandom.nextInt(listVide.size()));	
				listVide.clear();
								
				while ( mNiveau.Map[tab[0]+tmp[0]][tab[1]+tmp[1]] )
				{
					tab[0]+=tmp[0];
					tab[1]+=tmp[1];
					for(int[] t : pos)
					{
						if( (t[0] != tmp[0]) & (t[1] != tmp[1])   )
						{
							if ( mNiveau.Map[tab[0]+t[0]][ tab[1]+t[1]])
							{
								if (! mNiveau.Map[tab[0]-t[0]][ tab[1]-t[1]])
								{
									tmp2[0]=tab[0];
									tmp2[1]=tab[1];
									listVide.add(tmp2);
									tmp2 = new int[2] ;
								}
							}
						}
					}
					
				}
				tmp2[0]=tab[0];
				tmp2[1]=tab[1];
				listVide.add(tmp2);
				
				tmp2 = listVide.get(mRandom.nextInt(listVide.size()));
				tab[0] = tmp2[0];
				tab[1] = tmp2[1];
				mNiveau.Map[tab[0]][tab[1]]=false;
				listVide.clear();
				nbr ++;
				security = 0;
			}
			else
			{
				security ++;
				if ( security == mNbrAtome )
					nbr = mNbrMouvement;
			}
			
			i++;
		}
		for(int[] t : mListAtome )
		{
			mNiveau.Map[t[0]][t[1]]=true;
		}
	}
	public AtomixNiveau generateurNiveau(long niv){
		
		mListAtome = new ArrayList<int[]>();
		mListMolecul = new ArrayList<int[]>();
		mNiveau = new AtomixNiveau();
		mRandom = new Random();
		mNiveau.Niv = niv ;
		mNiveau.Id = Calendar.getInstance().getTimeInMillis();
		generateurValeur();
		
		generateurMap();
		generateurMolecule();
		generateurPuzzle();
		
		mNiveau.Atome = mListAtome;
		mNiveau.Molecul = mListMolecul;
		return mNiveau; 
	}
	
}
