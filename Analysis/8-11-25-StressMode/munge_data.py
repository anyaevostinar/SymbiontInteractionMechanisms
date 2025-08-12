import os.path
import gzip

metafolder = '../../Data/8-11-25-StressMode/'


folders = ["Mutualists", "NoSyms", "Parasites"]
partners = ["Host", "Sym"]
tasks = ["NOT", "NAND", "AND", "ORN", "OR", "ANDN", "NOR", "XOR", "EQU"]
reps = range(100,131)
header = "uid treatment rep update task count partner\n"

outputFileName = "munged_basic.dat"
outFile = open(outputFileName, 'w')
outFile.write(header)

for t in folders:
    for r in reps:
        fname = metafolder +t + "Tasks_" + t +"_SEED" + str(r)+ ".data"
        uid = t + "_" + str(r)      

        curFile = open(fname, 'r')
        for line in curFile:
            if (line[0] != "u"):
                splitline = line.strip().split(',')
                for task_i in range(1, len(splitline), 2):
                    task = tasks[(task_i-1)//2]
                    host_outstring = "{} {} {} {} {} {} {}\n".format(uid, t, r, splitline[0], task, splitline[task_i], "Host")
                    outFile.write(host_outstring)
                    sym_outstring = "{} {} {} {} {} {} {}\n".format(uid, t, r, splitline[0], task, splitline[task_i+1], "Symbiont")
                    outFile.write(sym_outstring)
        curFile.close()
outFile.close()


outputFileName2 = "munged_basic2.dat"
outFile2 = open(outputFileName2, 'w')
outFile2.write(header)

for t in treatment_postfixes:
    for r in reps2:
        fname = folder +"Tasks_" + t +"_SEED" + str(r)+ ".data"
        uid = t + "_" + str(r)
        if(os.path.isfile(fname) == False):
            continue        
       
        curFile = open(fname, 'r')
        for line in curFile:
            if (line[0] != "u"):
                splitline = line.strip().split(',')
                for task_i in range(1, len(splitline), 2):
                    task = tasks[(task_i-1)//2]
                    host_outstring = "{} {} {} {} {} {} {}\n".format(uid, t, r, splitline[0], task, splitline[task_i], "Host")
                    outFile2.write(host_outstring)
                    sym_outstring = "{} {} {} {} {} {} {}\n".format(uid, t, r, splitline[0], task, splitline[task_i+1], "Mutualist")
                    outFile2.write(sym_outstring)
        curFile.close()
outFile2.close()