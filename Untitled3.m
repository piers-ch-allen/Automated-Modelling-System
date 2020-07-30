#set up multithreaded pool
import multiprocessing as mp
import threading

pool = mp.Pool(processes=4)
threads=[]s

def JobCalc(num):
    currJob = jobArray[i]
    currJob.submit()
    currJob.waitForCompletion()

def JobThread(num)
`   t = threading.Thread(target=JobCalc, args=(num,))
    threads.append(t)
    t.start()

results = pool.map(JobThread, )
pool.close() 
pool.join() 


#run all the created jobs in parallel
counterLoad = 1
counterMesh = 1
for x in LoadMagnitudesArray:
    for y in MeshDensityArray:
        
        counterMesh = counterMesh + 1
    counterLoad = counterLoad + 1
    counterMesh = 1;
