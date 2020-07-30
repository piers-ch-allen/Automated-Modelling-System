import abaqus
import abaqusConstants as aq
from numpy import *

## Define the model and instance that is being worked with
print ModelName

# For top loading 
topFace = myInstance.edges.findAt(((XOrigin,GridSpaceY2,0),) )
myModel.parts['Part-1'].Surface(name='Surf-1', side1Edges=
    myModel.parts['Part-1'].edges.findAt(((XOrigin,GridSpaceY2,0), )))

## All of the different loads, choose the correct one
# Pressure Load
#myModel.Pressure(name='PressureLoad', createStepName='cartLoad', 
#    region=myModel.rootAssembly.instances['CartInstance'].surfaces['Surf-1'], magnitude=LoadMagnitude)

# Ramp load
myModel.Pressure(name='RampLoad', createStepName='rampLoad',
    region=myModel.rootAssembly.instances['CartInstance'].surfaces['Surf-1'], magnitude=LoadMagnitude)

# Cyclic Load
import amplitude
myModel.PeriodicAmplitude(name='CyclicAmp', timeSpan=aq.STEP, frequency=6.28, 
    start=0, a_0=0, data=[(0,0.388)])
myModel.Pressure(name='CyclicLoadPressure', createStepName='cyclicLoad', amplitude='CyclicAmp',
    region=myModel.rootAssembly.instances['CartInstance'].surfaces['Surf-1'], magnitude=LoadMagnitude)