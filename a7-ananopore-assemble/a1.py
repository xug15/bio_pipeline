import h5py
import numpy as np
import os
import sys

f2=h5py.File(sys.argv[1],'r')
dirpath=sys.argv[1][:-6]
print(dirpath)

os.mkdir(dirpath)
names=list(f2.keys())
for i in names:
    print(i)
    filepath=dirpath+'/'+i+'.fast5'
    print(filepath)
    f4=h5py.File(filepath,'w')
    f2.copy(i, f4)
    f4.close()

f2.close()



