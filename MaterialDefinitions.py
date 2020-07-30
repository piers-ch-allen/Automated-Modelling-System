import abaqus
import abaqusConstants as aq
from numpy import *
execfile('LoopVar.py')
currOgdenParam = OgdenParams[OgdenVal-1]
print(currOgdenParam)

## Define the material properties to the part and add the material section defintion.
# Linear Elastic
#myCartMat = myModel.Material(name='LinearCart')
#myCartMat.Elastic(table = ((ElasticMod,PoisonRatio),))
#mySection = myModel.HomogeneousSolidSection(material='LinearCart',
#       name='Section-Cartilage-Linear', thickness=None)

# Ogden Hyper Elastic model
myCartMat2 = myModel.Material(name='OgdenElastic')
myCartMat2.Hyperelastic(type=aq.OGDEN, testData = aq.OFF, moduliTimeScale=aq.LONG_TERM,
    n=3, table=((currOgdenParam),))
mySection = myModel.HomogeneousSolidSection(material='OgdenElastic',
       name='Section-Cartilage-Ogden', thickness=None)

#Prony Visco Elastic Model x1
#myCartMat3 = myModel.Material(name='PronyViscoElastic1')
#myCartMat3.Density(table=((1.1E-09, ), ))
#myCartMat3.Hyperelastic(type=aq.OGDEN, testData = aq.OFF, moduliTimeScale=aq.LONG_TERM,
#    n=3, table=[(-26133000,2.719,12922000,3.996,13227000,1.504,0,0,0),])
#myCartMat3.Viscoelastic(domain=aq.TIME, time=aq.PRONY, table=((0.744, 0.978, 13.3), ))
#mySection = myModel.HomogeneousSolidSection(material='PronyViscoElastic1',
#       name='Section-Cartilage-Prony', thickness=None)

#Prony Visco Elastic Model x1
#myCartMat4 = myModel.Material(name='PronyViscoElastic1')
#myCartMat4.Density(table=((1.1E-09, ), ))
#myCartMat4.Hyperelastic(type=aq.OGDEN, testData = aq.OFF, moduliTimeScale=aq.LONG_TERM,
#    n=3, table=((-26133000,2.719,12922000,3.996,13227000,1.504,0,0,0),))
#myCartMat4.Viscoelastic(domain=aq.TIME, time=aq.PRONY, table = ((0.0046,0,20.6073),(0.9615,0,1662),(0.0332,0,1662.1)))
#mySection2 = myModel.HomogeneousSolidSection(material='PronyViscoElastic3',
#     name='Section-Cartilage-Prony3', thickness=None)


#Assign section to the part
myCartPart.SectionAssignment(offset=0.0, offsetField='', offsetType = aq.MIDDLE_SURFACE, 
    region=FaceSet, sectionName = 'Section-Cartilage-Ogden', thicknessAssignment=aq.FROM_SECTION);