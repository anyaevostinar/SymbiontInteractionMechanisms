import os.path
import gzip

metafolder = '../../Data/11-11-25-VerticalTransTransEvol/'


folders = ["Parasites-0.0", "Parasites-0.1", "Parasites-0.2", "Parasites-0.3", "Parasites-0.4", "Parasites-0.5", "Parasites-0.6", "Parasites-0.7", "Parasites-0.8", "Parasites-0.9", "Parasites-1.0"]
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
                for task_i in range(1, len(splitline), 2):
                    task = tasks[(task_i-1)//2]
                    host_outstring = "{} {} {} {} {} {} {}\n".format(uid, t, r, splitline[0], task, splitline[task_i], "Host")
                    outFile.write(host_outstring)
                    sym_outstring = "{} {} {} {} {} {} {}\n".format(uid, t, r, splitline[0], task, splitline[task_i+1], "Symbiont")
                    outFile.write(sym_outstring)
        curFile.close()
outFile.close()