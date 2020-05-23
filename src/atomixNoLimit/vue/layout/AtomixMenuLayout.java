/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package atomixNoLimit.vue.layout;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.LayoutManager;
import java.util.HashMap;
import java.util.Map;



/**
 *
 * @author jonathan
 */
public class AtomixMenuLayout implements LayoutManager
{
    static final public String ARRIERPLAN = "B" ;
    static final public String PREMIERPLAN = "F" ;
    static final public String BOUTONQUITTER = "Q" ;
    static final public String BOUTONRECOMMENCER = "R" ;
    static final public String BOUTONCONTINUER = "C" ;
    static final public String BOUTONOPTIONS = "O" ;
    
        
    private Map<String , Component> mComponent = new HashMap<String, Component>() ;
    
    public void addLayoutComponent(String  name, Component comp) {
            mComponent.put(name, comp);
    }

    public void removeLayoutComponent(Component comp) {
        for(String g : mComponent.keySet() ){
            if( mComponent.get(g).equals(comp)){
                mComponent.remove(g);
            }
        }
    }

    public Dimension preferredLayoutSize(Container parent) {
        return null;
    }

    public Dimension minimumLayoutSize(Container parent) {
        return null;
    }

    public void layoutContainer(Container parent) {
               
        Component comp ;
        
        if( mComponent.containsKey(ARRIERPLAN)){
            comp = mComponent.get(ARRIERPLAN);
            comp.setBounds(parent.getX() , parent.getY() , parent.getWidth(), parent.getHeight());
        }
        if( mComponent.containsKey(PREMIERPLAN)){
            comp = mComponent.get(PREMIERPLAN);
            comp.setBounds(parent.getX() , parent.getY() , parent.getWidth(), parent.getHeight());
        }
        
        int dW =  (int) (( parent.getWidth()- 400)*0.5);
        int dH =  (int) ((parent.getHeight() - 550)*0.5);
        
        if( mComponent.containsKey(BOUTONCONTINUER)){
            comp = mComponent.get(BOUTONCONTINUER);
            comp.setBounds(parent.getX()+ dW  , parent.getY()+dH , 400,100);
        }        
	if( mComponent.containsKey(BOUTONRECOMMENCER)){
            comp = mComponent.get(BOUTONRECOMMENCER);
            comp.setBounds(parent.getX()+ dW  , parent.getY()+150+dH , 400, 100);
        }
        if( mComponent.containsKey(BOUTONOPTIONS)){
            comp = mComponent.get(BOUTONOPTIONS);
            comp.setBounds(parent.getX()+ dW , parent.getY()+ 300 +dH , 400, 100);
        }
        if( mComponent.containsKey(BOUTONQUITTER)){
            comp = mComponent.get(BOUTONQUITTER);
            comp.setBounds(parent.getX()+ dW  , parent.getY()+ 450 +dH , 400, 100);
        }
    }

   
    
}
