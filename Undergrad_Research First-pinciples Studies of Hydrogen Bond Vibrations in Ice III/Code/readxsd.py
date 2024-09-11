import os
import sys
import tkinter.filedialog as tkf
import xml.dom.minidom as xmldom
import numpy as np

def readatom(xsdPath):
    global NOxygen
    global LattVector
    global adjoint
    if xsdPath == '':
        print("Please choose a structure file")
        xsdPath = tkf.askopenfilename(filetypes=[('XSD', 'xsd')])
        if xsdPath == '':
            print('No chosen file')
            sys.exit(0)
        else:
            print('--xsdfile="' + xsdPath + '"')
    xsdFile = xmldom.parse(xsdPath)
    StruElement = xsdFile.documentElement
    SpaceGroup = StruElement.getElementsByTagName("SpaceGroup")
    Atom3d = StruElement.getElementsByTagName("Atom3d")
    AVector = np.array(list(map(float, SpaceGroup[0].getAttribute("AVector").split(","))))
    BVector = np.array(list(map(float, SpaceGroup[0].getAttribute("BVector").split(","))))
    CVector = np.array(list(map(float, SpaceGroup[0].getAttribute("CVector").split(","))))
    NHydorgen = 0
    NOxygen = 0
    for atom in Atom3d:
        if atom.getAttribute("Components") == "H":
            NHydorgen += 1
        elif atom.getAttribute("Components") == "O":
            NOxygen += 1