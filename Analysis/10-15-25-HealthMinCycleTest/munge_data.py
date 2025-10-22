import os.path
import gzip

metafolder = '../../Data/10-15-25-HealthMinCycleTest/'


folders = ["Parasites-80-25", "Parasites-100-25", "Parasites-150-25"]
partners = ["Host", "Sym"]
tasks = ["NOT", "NAND", "AND", "ORN", "OR", "ANDN", "NOR", "XOR", "EQU"]
reps = range(100,131)
header = "uid treatment rep update task count partner\n"

outputFileName = "munged_basic.dat"
outFile = open(outputFileName, 'w')
outFile.write(header)

for t in folders:
    for r in reps:
        fname = metafolder +t+"/"+str(r)+"/" + "Tasks_" + t +"_SEED" + str(r)+ ".data"
        uid = t + "_" + str(r)      

        curFile = open(fname, 'r')
        for line in curFile:
            if (line[0] != "u"):
                splitline = line.strip().split(',')
                update = splitline[0]
                sym_steal_ran = splitline[1] 
                sym_donate_ran = splitline[2]
                outstring = "{} {} {} {} {} {}\n".format(uid, t, r, update, sym_steal_ran, sym_donate_ran)
                outFile.write(outstring)
        curFile.close()
        curFile.close()
outFile.close()
