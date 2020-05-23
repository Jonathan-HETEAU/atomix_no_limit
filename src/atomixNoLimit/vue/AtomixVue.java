package atomixNoLimit.vue;

import java.awt.CardLayout;
import java.awt.Container;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import javax.swing.JFrame;
import atomixNoLimit.controleur.AtomixControleur;

public class AtomixVue extends JFrame implements WindowListener {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private CardLayout mPile = new CardLayout();
	private AtomixControleur mControl ;
	private Container mConteneur;
	
	public AtomixVue(AtomixControleur atomixControleur ,AtomixMenuVue menu ,
			AtomixPartieVue partie , AtomixMoleculeVue molecule) {
		// TODO Auto-generated constructor stub
		this.setTitle("Atomix");
		this.setLayout(this.mPile);
		this.mControl = atomixControleur;
		this.mConteneur = getContentPane();
		
		this.mConteneur.add( menu , "Menu");
		this.mConteneur.add( partie , "Partie"); 
		this.mConteneur.add( molecule, "Molecule");
		
		this.mPile.show(this.mConteneur,"Menu");
		
		this.addWindowListener(this);
				
		this.setSize(800,800);
		this.setVisible(true);
		
		
		
	}

	public void show(String type){
		this.mPile.show(this.mConteneur,type);
		repaint();
	}
	

	@Override
	public void windowActivated(WindowEvent e) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void windowClosed(WindowEvent e) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void windowClosing(WindowEvent e) {
		// TODO Auto-generated method stub
		mControl.sauvegarder();
		System.exit(0);
	}


	@Override
	public void windowDeactivated(WindowEvent e) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void windowDeiconified(WindowEvent e) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void windowIconified(WindowEvent e) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void windowOpened(WindowEvent e) {
		// TODO Auto-generated method stub
		
	}
	
	
	
	
}
