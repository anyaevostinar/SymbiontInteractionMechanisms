import os.path
import gzip

metafolder = '../../Data/11-11-25-VerticalTransNoTransEvol/'


folders = ["Parasites-0.0", "Parasites-0.1", "Parasites-0.2", "Parasites-0.3", "Parasites-0.4", "Parasites-0.5", "Parasites-0.6", "Parasites-0.7", "Parasites-0.8", "Parasites-0.9", "Parasites-1.0"]
reps = range(100,131)
header = "uid treatment rep update sym_steal_ran sym_donate_ran"

outputFileName = "munged_syminstcount.dat"
outFile = open(outputFileName, 'w')
outFile.write(header+"\n")

for t in folders:
    for r in reps:
        fname = metafolder +t+"/"+str(r)+"/" + "SymInstCount_" + t +"_SEED" + str(r)+ ".data"
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
outFile.close()
