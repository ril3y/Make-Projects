#!/usr/bin/python

import serial
from math import *
from time import sleep

move = 0, 0, 2

class wirebot(object):
    def __init__(self):
        #Machine Specific
        PORT = "COM30" #Set your serial port here
        BAUD = 9600 #This should be 9600 unless you are using a custom grbl build.
        
        
        self.ZER0 = (0,0,0)
        self.s  = serial.Serial(PORT, BAUD)  #Set your serial port here
        
        
        """SETTINGS
        This is where you need to setup the settings for your machine.
        This example is a 610mm x 610mm x 610mm (24" x 24" x 24")
        
         -     X      +      
        ----------------        
        |      V3      |  +
        |      /\      |
        |     /  \     |      Note: The center of the Triangle is (0,0,0)
        |    /    \    |  Y
        |   /      \   |
        | V1--------V2 |  
        ----------------  -
        UP = + for Z
        DOWN = - for Z
        
        We use a 2'x 2' frame for this project.  So Roughly 24/2 = 12.  But we use 11.5 
        
                X    Y    Z  
        ---------------------------------
        V1 = (-12, -12,  12)  #Left Vertex
        V2 = ( 12, -12,  12)  #Right Vertex
        V3 = (  0,  12,  12)  #Rear Vertex
        

        The above example assumes the vertices are all at the same height, but they don�t have to be. 
        Just enter the actual height from the origin (Which is 0,0,0 Or the center of the triangle). The example also assumes that the rear vertex is 
        half way between the left and right in X, but it doesn�t have to be.  The positions of the vertices
        are somewhat arbitrary, assuming you don�t reduce the useful working volume too much.
        
        What does that mean?  It does not have to be a perfect equilateral triangle.  Or that each vertex does not need
        to be at the same height as the others.  However each "offset" will cut into your working volume area.
        
        """
         
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
        
        v = 8
        self.CUBE = [ (-v,-v,v),
                      (v,-v,v),
                      (v,v,v),
                      (-v,v,v),
                      (-v,v,-v),
                      (v,v,-v),
                      (v,-v,-v),
                      (-v,-v,-v),
                      (0,0,0) ]
        
    def Zero(self):
        print("Zeroing Function Called")
        L1, L2, L3 = self.baseEQ(self.ZER0)
        
        print("G92 X%s Y%s Z%s\n" % (L1, L2, L3))
        self.s.writelines("G92 X%s Y%s Z%s\n" % (L1, L2, L3))
        print "HI"
        
    def Cube(self):
        value = self.Zero()
        for coord in self.CUBE:
            
            value = self.baseEQ(coord)
            print ("Sending: G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            self.s.writelines("G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            sleep(4)

        
        
        
    def baseEQ(self, value):
        """L means string len"""
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
    
        
        
COMMANDS = [(0,0,6),(5,5,5),(0,0,0)]


print "STARTING:"

"""
#z = wirebot()
#L1, L2, L3 = z.baseEQ((0,0,0))
#z.s.write("G92 X%s Y%s Z%s\n" % (L1, L2, L3))
#for cmd in COMMANDS:
    #L1,L2,L3 = z.baseEQ(cmd)
    ##z.s.write("G1 F800 X%s Y%s Z%s\n" % (L1,L2,L3))
    #sleep(3)
"""
z = wirebot()
#L1, L2, L3 = z.baseEQ((0,0,0)) #Set our 0,0,0 through the BaseEQ function to our G92
while(1):    
    z.Cube()
#z.s.writelines("G20\n")


#while(1):
    #value = z.baseEQ((0,0,6))
    #print ("Sending: G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
    #z.s.writelines("G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
    #sleep(2)
    
    #value = z.baseEQ((0,0,0))
    #print ("Sending: G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
    #z.s.writelines("G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
    #sleep(2)
    