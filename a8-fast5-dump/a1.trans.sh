output=sig
h5totxt(){
[ -d ${output}  ] || mkdir -p ${output}
	
h5dump ${name} > ${output}/${name}.txt

}

extrfq()
{
perl a3.fq.pl ${output}/${name}.txt

}


exsig(){
perl a2.sig.pl ${output}/${name}.txt
}


run_one_step(){

for i in `ls |grep fast5$`;do 
	echo $i;
	name=$i;
h5totxt
extrfq
exsig
done
	
#h5totxt
#extrfq
#exsig

}


run_one_step


