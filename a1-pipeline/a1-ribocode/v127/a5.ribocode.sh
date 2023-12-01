
outdir=output
ribocodeann=/home/xugang/data/zouqing/output/a7-ribocode_annotation
config=config.txt
config=total.txt
ribocoderesult=${outdir}/a9-ribocode-result

[[ -d $ribocoderesult ]] || mkdir -p $ribocoderesult


echo "RiboCode -a $ribocodeann -c $config -l no -g -o $ribocoderesult"
RiboCode -a $ribocodeann -c $config -l no -g -o $ribocoderesult



