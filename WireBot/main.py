#!/bin/bash

import wx
from wx import xrc
 

class Config(object):
    def __init__(self):
        self.x1 = -11
        self.y1 = -11.5
        self.z1 = 12.5
        
        self.x2 = 11
        self.y2 = -11.5
        self.z2 = 12.5
        
        self.x3 =  0
        self.y3 = 11.5
        self.z3 = 11.5
        
        self.v1 =  (self.x1, self.y1, self.z1)
        self.v2 =  (self.x2, self.y2, self.z2)
        self.v3 =  (self.x3, self.y3, self.z3)
        
class WireBot(wx.App):
    def OnInit(self):
        self.res = xrc.XmlResource("wirebot.xrc")
        self.frame = self.res.LoadFrame(None, 'MainFrame')
        self.frame.Show()
        self.config = Config() #Load the config
        
        #Buttons
        #self.btn_right = xrc.XRCCTRL(self.frame, 'btn_right')
        self.frame.Bind(wx.EVT_BUTTON, self.OnRight, id=xrc.XRCID("btn_right"))
        
        
    
    def baseEQ(self, value):
        """This function will convert normal GCODE commands \
        to our 3 axis kinetic model L means string len"""
        
        x1,y1,z1 = self.v1
        x2,y2,z2 = self.v2
        x3,y3,z3 = self.v3
        
        """This is ugly.  Dont kiss you mother with this code."""
        lvalue = []
        lvalue.append(value[0])
        lvalue.append(value[1])
        lvalue.append(value[2])
        #This for inverting Z 
        
        x,y,z = lvalue[0],lvalue[1],lvalue[2]
        
        
        L1 = sqrt((x1-x)**2 + (y1-y)**2 + (z1-z)**2)
        L2 = sqrt((x2-x)**2 + (y2-y)**2 + (z2-z)**2)
        L3 = sqrt((x3-x)**2 + (y3-y)**2 + (z3-z)**2)
        #print ("Sent: (%s,%s,%s)\nReturned: (%2.2f,%2.2f,%2.2f)" % (x,y,z,L1,L2,L3))
        val = ("%2.2f,%2.2f,%2.2f") % (L1,L2,L3)
        
        return val.split(",")
    
    
        
        return True
    def OnRight(self, evt):
        print "Moving Right"
 
if __name__ == "__main__":
    app = WireBot(False)
    app.MainLoop()