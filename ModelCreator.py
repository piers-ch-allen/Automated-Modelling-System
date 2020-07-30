#Load variables and imports
import abaqus
import abaqusConstants as aq
from part import *
from material import *
from section import *
from assembly import *
from numpy import *
execfile('Var.py')

# Create a model.
modelName = '2DBeam_Load' + str(counterLoad) + '_Mesh' + str(counterMesh)
myModel = mdb.Model(name=modelName, modelType=aq.STANDARD_EXPLICIT)

#-----------------------------------------------------
#Create rectangle with variable size
mySketch = myModel.ConstrainedSketch(name='__profile__', sheetSize=maxHeight)
mySketch.setPrimaryObject(option=aq.STANDALONE)

#Define the part sizings and define the part properties
mySketch.rectangle(point1=(GridSpaceX1, GridSpaceY1), point2=(GridSpaceX2, GridSpaceY2))

#2D deformable object
myCartPart = myModel.Part(dimensionality=aq.TWO_D_PLANAR, name='Part-1', type=
    aq.DEFORMABLE_BODY)

#3D deformable object
#myCartPart = myModel.Part(name='Beam', dimensionality=THREE_D,
#    type=DEFORMABLE_BODY)
#myCartPart.BaseSolidExtrude(sketch=mySketch, depth=ZDistance)

#Sketch the part
myCartPart.BaseShell(sketch=mySketch)
mySketch.unsetPrimaryObject()
del myModel.sketches['__profile__']

#Create the viewpoint
myViewport = session.Viewport(name='Cartilage-Load-Example',
    origin=(0, 0), width=maxWidth, height=maxHeight)

#Get the geometric objects from the part
edges1 = myCartPart.edges
vertices1 = myCartPart.vertices
face1 = myCartPart.faces

#Create sets for edges and face for later use
myCartPart.Set(name='Top', edges=edges1.findAt(((XOrigin,GridSpaceY2,0) ,)))
myCartPart.Set(name='Bottom', edges=edges1.findAt(((XOrigin,GridSpaceY1,0) ,)))
myCartPart.Set(name='MainFace', faces=face1.findAt(((XOrigin, YOrigin,0),)))
#Create accesible objects for sets
FaceSet = myCartPart.sets['MainFace'];
TopSet = myCartPart.sets['Top'];
BottomSet = myCartPart.sets['Bottom'];
#-----------------------------------------------------
#Add Material Properties & section assignments through MaterialDefinitions.py
# Define all the different load patterns within the LoadDefinitions Python File.
MaterialParameter = {'ElasticMod': ElasticMod, 'PoisonRatio': PoisonRatio, 
    'myModel': myModel, 'myCartPart':myCartPart, 'FaceSet':FaceSet}
execfile('MaterialDefinitions.py', MaterialParameter)

#-----------------------------------------------------
# Create a part instance.
myModel.rootAssembly.DatumCsysByDefault(aq.CARTESIAN)
myInstance = myModel.rootAssembly.Instance(name='CartInstance',part=myCartPart, dependent=ON)

#create reference to the assembly sets
assemblyTop = myModel.rootAssembly.instances['CartInstance'].sets['Top']
assemblyBottom = myModel.rootAssembly.instances['CartInstance'].sets['Bottom']

#-----------------------------------------------------
# Create a step. The time period of the static step is 1.0, 
# and the initial incrementation is 0.1; the step is created
# after the initial step. 
InitStep = myModel.StaticStep(name='rampLoad', previous='Initial', nlgeom=ON,
    timePeriod=1, initialInc=0.01,minInc=1E-08, maxInc=1,maxNumInc=10000000,
    continueDampingFactors=True, adaptiveDampingRatio=0.05,
    description='Ramp load the top face of the cartilage.')
myModel.ViscoStep(name='cyclicLoad', 
        previous='rampLoad',nlgeom=ON, timePeriod=3.0, maxNumInc=100000, 
        stabilizationMethod=aq.DISSIPATED_ENERGY_FRACTION, 
        continueDampingFactors=True, adaptiveDampingRatio=0.05, 
        initialInc=0.01, minInc=3e-05, maxInc=0.01, cetol=100000.0, 
        integration=aq.EXPLICIT_ONLY, extrapolation=aq.PARABOLIC, 
        solutionTechnique=aq.QUASI_NEWTON, description='Cyclic load the top face of the cartilage.')
#-----------------------------------------------------
# Create a boundary condition that encastres the bottom of the cartilage
myModel.EncastreBC(name='BottomBoundary',createStepName='Initial',
    region=assemblyBottom)
myModel.XsymmBC(name='TopBoundary',createStepName='Initial',
    region=assemblyTop)

#-----------------------------------------------------
# Add load definition
# Define all the different load patterns within the LoadDefinitions Python File.
LoadParameter = {'ModelName': modelName, 'myModel': myModel, 'myInstance':myInstance,
    'XOrigin':XOrigin, 'GridSpaceY2':GridSpaceY2, 'LoadMagnitude':LoadMagnitude}
execfile('LoadDefinitions.py', LoadParameter)

#-------------------------------------------------------
# Mesh and seed the part that has bene created.
myCartPart.seedPart(size=MeshSize)
myCartPart.generateMesh()
myAssembly = myModel.rootAssembly
myModel.rootAssembly.regenerate()

# Display the meshed beam.
myViewport.assemblyDisplay.setValues(mesh=ON)
myViewport.assemblyDisplay.meshOptions.setValues(meshTechnique=ON)
myViewport.setValues(displayedObject=myAssembly)

#-------------------------------------------------------
# Define the job for the model and submit it.

jobName = 'Cart_Load_Practice_Load' + str(counterLoad) + '_Mesh' + str(counterMesh)
myJob = mdb.Job(name=jobName, model=modelName,
    description='Cartilage Beam Load')