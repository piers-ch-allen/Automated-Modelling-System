#Created by Piers Allen
#09/01/2019

import abaqus
import abaqusConstants as aq
from numpy import *

#Load variables
execfile('LoopVar.py')

#Start of the Loop
#initialise all the different values
counterLoad = 1
counterMesh = 1
counterOgden = 1
totalNumJobs = 0
sizeMesh = len(MeshDensityArray)
for x in LoadMagnitudesArray:
    for y in MeshDensityArray:  
        for z in range(1,len(OgdenParams)+1):
            #initialise the new model with magnitues and mesh size
            localParameter = {'LoadMagnitude': x, 'MeshSize': y, 'OgdenParams':z, 'counterLoad': counterLoad, 
                'counterMesh':counterMesh, 'counterOgden':counterOgden}

            #exec the sub python file
            execfile('ModelCreator.py', localParameter)
            print(counterOgden)
            counterOgden = counterOgden + 1;
            totalNumJobs = totalNumJobs + 1
        counterOgden = 1;
        counterMesh = counterMesh + 1
    counterLoad = counterLoad + 1
    counterMesh = 1;

#Create pool of all of the jobs
JobsArray = list()
JobsNameArray = list()
for x in range(1,len(LoadMagnitudesArray) + 1):
    for y in range(1,len(MeshDensityArray) + 1):
        for z in range(1,len(OgdenParams)+1):
            index = 5*(x-1) + y 
            JobsName = 'Cart_Load_Practice_Load' + str(x) + '_Mesh' + str(y) + '_Ogden' + str(z)
            ModelName = '2DBeam_Load' + str(x) + '_Mesh' + str(y) + '_Ogden' + str(z)
            myJob = mdb.Job(name=JobsName, model=ModelName)
            JobsArray.append(myJob)
            JobsNameArray.append(JobsName)

#get current working directory
import os 
cwd = os.getcwd()
mdb.saveAs(cwd+'/trialModels');
#run the jobs and save the outputs in files of their own.
for x in range(0,len(JobsArray)):
    Job = JobsArray[x]	
    newDir = cwd + '/' + JobsNameArray[x]
    if not os.path.exists(newDir):
        os.mkdir(newDir)
    os.chdir(newDir)
    rem = int(float((JobsNameArray[x])[29]))-1
    try:
        Job.submit()
        Job.waitForCompletion()

        #report current values to abacus report sheet within same file location
        from odbAccess import *
        from visualization import *
        odbname = cwd + '/' + JobsNameArray[x] + '/' + JobsNameArray[x] + '.odb'
        ODB = session.openOdb(name = odbname)
        ODBsesh = session.odbs[odbname]
        session.viewports['Viewport: 1'].setValues(displayedObject=ODB)
        session.mdbData.summary()
        if MeshDensityArray[rem] == 0.0001:
            session.xyDataListFromField(odb=ODBsesh, outputPosition=aq.NODAL, variable=(('U', 
                aq.NODAL, ((aq.INVARIANT, 'Magnitude'), )), ), nodePick=(('CARTINSTANCE', 1, ('[#0:26 #8000 ]', )), ), )
            x0 = session.xyDataObjects['U:Magnitude PI: CARTINSTANCE N: 848']
            session.writeXYReport(fileName='abaqus.rpt', xyData=(x0, )) 
            del session.xyDataObjects['U:Magnitude PI: CARTINSTANCE N: 848']  
        elif MeshDensityArray[rem] == 0.00015:
            session.xyDataListFromField(odb=ODBsesh, outputPosition=aq.NODAL, variable=(('U', 
                aq.NODAL, ((aq.INVARIANT, 'Magnitude'), )), ), nodePick=(('CARTINSTANCE', 1, ('[#0:12 #400000 ]', )), ), )
            x0 = session.xyDataObjects['U:Magnitude PI: CARTINSTANCE N: 407']
            session.writeXYReport(fileName='abaqus.rpt', xyData=(x0, )) 
            del session.xyDataObjects['U:Magnitude PI: CARTINSTANCE N: 407']  
        elif MeshDensityArray[rem] == 0.0002:   
            session.xyDataListFromField(odb=ODBsesh, outputPosition=aq.NODAL, variable=(('U', 
                aq.NODAL, ((aq.INVARIANT, 'Magnitude'), )), ), nodePick=(('CARTINSTANCE', 1, ('[#0:7 #2 ]', )), ), )
            x0 = session.xyDataObjects['U:Magnitude PI: CARTINSTANCE N: 226']
            session.writeXYReport(fileName='abaqus.rpt', xyData=(x0, )) 
            del session.xyDataObjects['U:Magnitude PI: CARTINSTANCE N: 226']
    except:
        print("too many nodes");
    os.chdir(cwd)