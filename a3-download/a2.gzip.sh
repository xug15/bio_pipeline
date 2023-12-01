for i in `ls`;
do 
	if [ -d $i ]; then
		echo $i;
		for j in `ls $i/rawdata|grep -v gz`;do
			echo $i/rawdata/$j;
			gzip $i/rawdata/$j
		done
	fi
done



