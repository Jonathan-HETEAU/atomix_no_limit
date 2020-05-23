package atomixNoLimit.model.atomixBaseClass;

import java.util.Arrays;

public class AtomixSauvegarde  {

	public long Id = 0;
	public int[][][] mMoveList ;
	public int[][] mAtomeList ;
	
		
	@Override
	public String toString() {
		return "AtomixSauvegarde [Id=" + Id + ", mMoveList="
				+ Arrays.toString(mMoveList) + ", mAtomeList="
				+ Arrays.toString(mAtomeList) + "]";
	}
	
	
}
