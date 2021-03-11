import abaqus
import abaqusConstants as aq
import numpy 
execfile('LoopVar.py')
currOgdenParam = OgdenParams[OgdenVal-1]
a = "Visco"
b = str(ViscoVal)
exec("currViscoParam = " + a + b )
#currViscoParam = numpy.transpose(currViscoParam)
import sys
current = []
for x in range(0,len(currViscoParam[1])):
    sub = []
    for y in range(0,len(currViscoParam)):
        sub.append(currViscoParam[y][x])
    current.append(sub)

## Define the material properties to the part and add the material section defintion.
# Linear Elastic
#myCartMat = myModel.Material(name='LinearCart')
#myCartMat.Elastic(table = ((ElasticMod,PoisonRatio),))
#mySection = myModel.HomogeneousSolidSection(material='LinearCart',
#       name='Section-Cartilage-Linear', thickness=None)

# Ogden Hyper Elastic model
#myCartMat2 = myModel.Material(name='OgdenElastic')
#myCartMat2.Hyperelastic(type=aq.OGDEN, testData = aq.OFF, moduliTimeScale=aq.LONG_TERM,
#    n=3, table=((currOgdenParam),))
#mySection = myModel.HomogeneousSolidSection(material='OgdenElastic',
#       name='Section-Cartilage-Ogden', thickness=None)

#Prony Visco Elastic Model x1
#myCartMat3 = myModel.Material(name='PronyViscoElastic1')
#myCartMat3.Density(table=((1.1E-09, ), ))
#myCartMat3.Hyperelastic(type=aq.OGDEN, testData = aq.OFF, moduliTimeScale=aq.LONG_TERM,
#    n=3, table=[(-26133000,2.719,12922000,3.996,13227000,1.504,0,0,0),])
#myCartMat3.Viscoelastic(domain=aq.TIME, time=aq.PRONY, table=((0.744, 0.978, 13.3), ))
#mySection = myModel.HomogeneousSolidSection(material='PronyViscoElastic1',
#       name='Section-Cartilage-Prony3', thickness=None)

#Prony Visco Elastic Model x1
myCartMat4 = myModel.Material(name='PronyViscoElastic1')
myCartMat4.Density(table=((1.1E-09, ), ))
myCartMat4.Hyperelastic(type=aq.OGDEN, testData = aq.OFF, moduliTimeScale=aq.LONG_TERM,
    n=3, table=((currOgdenParam),))
myCartMat4.Viscoelastic(domain=aq.TIME, time=aq.PRONY, table = current )
mySection2 = myModel.HomogeneousSolidSection(material='PronyViscoElastic1',
     name='Section-Cartilage-Prony3', thickness=None)


#Assign section to the part
myCartPart.SectionAssignment(offset=0.0, offsetField='', offsetType = aq.MIDDLE_SURFACE, 
    region=FaceSet, sectionName = 'Section-Cartilage-Prony3', thicknessAssignment=aq.FROM_SECTION);