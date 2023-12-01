from ont_fast5_api.fast5_interface import get_fast5_file
fast5_filepath='/home/xugang/data/ZJR-Nanopore/b6-new-meth/publish/rawdata/sd.fast5'
print (fast5_filepath);
with get_fast5_file(fast5_filepath, mode="r") as f5:
    for read_id in f5.get_read_ids():
        read = f5.get_read(read_id)
        latest_basecall = read.get_latest_analysis('Basecall_1D') 
        mod_base_table = read.get_analysis_dataset( latest_basecall, 'BaseCalled_template/ModBaseProbs') 
        print(read_id, mod_base_table)



