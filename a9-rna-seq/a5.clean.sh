for i in `ls`;do
	if [ -d $i ]; then
		echo $i;
		for j in `ls $i|grep fastq$`;do
			echo $i/$j
			rm $i/$j
		done
	fi
done

for i in `ls b2-rmrRNA`;do
        if [ -d b2-rmrRNA/$i ]; then
                echo b2-rmrRNA/$i;
                for j in `ls b2-rmrRNA/$i|grep fq$`;do
                        echo b2-rmrRNA/$i/$j
                        rm b2-rmrRNA/$i/$j
                done
        fi
done


