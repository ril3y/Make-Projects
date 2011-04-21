#!/usr/bin/python
try:    
    import serial, sys
except:
    print "Error Importing the Serial Module"
    print "You can download the serial port module here"
    print "\thttp://pypi.python.org/pypi/pyserial"
    
from math import *
from time import sleep

move = 0, 0, 2

class wirebot(object):
    def __init__(self):
        
        #Machine Specific
        PORT = "COM30" #Set your serial port here.
        BAUD = 9600 #This should be 9600 unless you are using a custom grbl build.
        
            
        """THIS IS WHERE YOU SET THE VERTICE'S VALUES"""   
        #V1 or Vertice 1 information
        self.x1 = -12
        self.y1 = -12
        self.z1 =  12
        
        #V2 or Vertice 2 information
        self.x2 =  12
        self.y2 = -12
        self.z2 =  12

        #V3 or Vertice 3 information
        self.x3 =  0
        self.y3 =  12
        self.z3 =  12
        
       
        """LEAVE THIS ALONE SET THE VERTICIE'S ABOVE"""
        self.v1 =  (self.x1, self.y1, self.z1) #Maps to Motor Port X on grblShield
        self.v2 =  (self.x2, self.y2, self.z2) #Maps to Motor Port Y on grblShield
        self.v3 =  (self.x3, self.y3, self.z3) #Maps to Motor Port Z on grblShield
        self.ZER0 = (0,0,0)
        
        
        
        """SETTINGS
        This is where you need to setup the settings for your machine.
        This example is a X,Y,Z (24" x 24" x 24")
        
         -     X      +      
        ----------------  +     
        |      V3      |  
        |      /\      |
        |     /  \     |  Y    Note: The center of the Triangle is (0,0,0)
        |    /    \    |  
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
        

        The above example assumes the vertices are all at the same height, but they donât have to be. 
        Just enter the actual height from the origin (Which is 0,0,0 Or the center of the triangle). The example also assumes that the rear vertex is 
        half way between the left and right in X, but it doesnât have to be.  The positions of the vertices
        are somewhat arbitrary, assuming you donât reduce the useful working volume too much.
        
        What does that mean?  It does not have to be a perfect equilateral triangle.  Or that each vertex does not need
        to be at the same height as the others.  However each "offset" will cut into your working volume area.
        
        """
        
        #This will setup your serial port connection
        try:
            self.s  = serial.Serial(PORT, BAUD) 
        except:
            print "Error Opening Serial Port"
            print "Make sure you have set this correctly in the code."
            print "If you are using windows the format is like this: COM3, etc"
            print "If you are on *nix its /dev/sttyUSB or something similar"
            print "Program Exiting...."
            sys.exit()
        
        
            
            
        """This might look confusing but these are just pre-defined shapes broken down into coodinates.
        Meaning CUBE will draw a cube with your center "ball" or whatever in 3d space.  In my example machine I used
        a 2' x 2' Cube.  This is a very small working area.  However should you have a larger area and you want to draw a bigger 
        cube then set the v value to something larger than 8."""
        
        #3d Cube
        self.CUBE = [ (-v,-v,v),
                      (v,-v,v),
                      (v,v,v),
                      (-v,v,v),
                      (-v,v,-v),
                      (v,v,-v),
                      (v,-v,-v),
                      (-v,-v,-v),
                      (0,0,0) ]
        
        #Not sure if this one works
        self.LETTER_M =  [(0,0,v),
                          (2,0,0),
                          (4,0,8),
                          (4,0,0)]
                          
        
        #This one draws an inverted pyramid
        self.INVERSE_TRIANGLE = [(-v,-v,v),
                                 (0,0,0),
                                 (v,-v,v),
                                 (0,0,0),
                                 (v,v,v),
                                 (0,0,0),
                                 (-v,v,v),
                                 (0,0,0)]
        
        #This SHOULD draw a 2d square
        self.VERT_SQUARE = [(-v,-v,v),
                            (-v,-v,-v),
                            (v,-v,-v),
                            (v,-v,v),
                            (-v,-v,v) ]
        
        
       
    

    def ConfigureLoop(self):
        """This method is used to make sure your motors are all hooked up and working correctly.
        When you run this loop your center object (in our example was a ping pong ball) should be moving 
        up then pausing for 2 seconds then moving back down.  Over and over.  Once you see this is the 
        case then your machine is at least working correctly a little bit. :)  """
        
        MOVENMENT_LENGTH = 6
        DELAY = 2
        print "In Configuration Loop... Hit CTRL-C to break this loop..."
        while(1):
            value = self.baseEQ((0,0,MOVENMENT_LENGTH))
            print ("Sending: G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            self.s.writelines("G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            sleep(DELAY)
            
            value = self.baseEQ((0,0,0))
            print ("Sending: G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            self.s.writelines("G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            sleep(DELAY)
        print "In Configuration Loop... Hit CTRL-C to break this loop..."


        
    def Zero(self):
        """This is the zeroing function.  This function
        once ran, should return the length of line to (0,0,0) from each vertex"""
        
        print("Zeroing Function Called")
        L1, L2, L3 = self.baseEQ(self.ZER0)
        print("G92 X%s Y%s Z%s\n" % (L1, L2, L3))
        self.s.writelines("G92 X%s Y%s Z%s\n" % (L1, L2, L3))
       
    
    def playShape(self, shape):
        """This takes a pattern and will play it on wirebot rig"""
        
        for coord in shape:
            value = self.baseEQ(coord)
            print ("Sending: G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            self.s.writelines("G0 X%s Y%s Z%s\n" % (value[0],value[1],value[2]))
            sleep(3)

        
    def baseEQ(self, value):
        """This is the master equation to translate normal 3 axis gcode
        into the 3 motor kinetic model"""
        x1,y1,z1 = self.v1
        x2,y2,z2 = self.v2
        x3,y3,z3 = self.v3
        
        """This is ugly.  Dont kiss you mother with this code."""
        lvalue = []
        lvalue.append(value[0])
        lvalue.append(value[1])
        lvalue.append(value[2])
        
        x,y,z = lvalue[0],lvalue[1],lvalue[2]
        
        L1 = sqrt((x1-x)**2 + (y1-y)**2 + (z1-z)**2)
        L2 = sqrt((x2-x)**2 + (y2-y)**2 + (z2-z)**2)
        L3 = sqrt((x3-x)**2 + (y3-y)**2 + (z3-z)**2)
        #print ("Sent: (%s,%s,%s)\nReturned: (%2.2f,%2.2f,%2.2f)" % (x,y,z,L1,L2,L3))
        val = ("%2.2f,%2.2f,%2.2f") % (L1,L2,L3)  #This will break down long gcode values into 2 decimal points
        
        return val.split(",")
    

print "[*]Starting the Wirebot Controller:"
if __name__ == "__main__":
    wb = wirebot()      #Creates a witebot object
    wb.Zero()
    wb.ConfigureLoop()  #Runs the configuration loop
    
    
    """Un-Comment this if you would like to continue to draw inverse triangles"""
    #while(1):
    #    wb.playShape(wb.INVERSE_TRIANGLE)
        
