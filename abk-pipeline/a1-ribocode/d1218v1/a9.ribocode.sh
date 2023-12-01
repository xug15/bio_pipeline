outdir=output
ribocodeann=output/a7-ribocode_annotation
config=total.txt
ribocoderesult=${outdir}/a9-ribocode-result/ribocode

generatef(){
echo -e "#name\tbam\tstrand\tlength\tpsite" > total.txt
for i in `ls $outdir/a8-ribocode|grep txt`;do
	echo $i;
	grep -v '#' $outdir/a8-ribocode/$i |grep -v '^$' >> total.txt
done
	
}
generatef
ribocodef(){

[[ -d $ribocoderesult ]] || mkdir -p $ribocoderesult


echo "RiboCode -a $ribocodeann -c $config -l no -g -o $ribocoderesult"
RiboCode -a $ribocodeann -c $config -l no -g -o $ribocoderesult
}
# ribocodef



