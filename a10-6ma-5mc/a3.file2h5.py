import h5py
import sys
import os

os.system(' [ -d splitdir ] || mkdir -p splitdir')


print(sys.argv[1])
hf = h5py.File(sys.argv[1], 'r')

name=[key for key in hf.keys()]



for i in name:
    #print(i)
    filename='splitdir/'+str(i)+'.fast5'
    #print (filename)
    hfo = h5py.File(str(filename), 'w')
    #g1 = hfo.create_group(i)
    hf.copy(i,hfo)
    hfo.close()














