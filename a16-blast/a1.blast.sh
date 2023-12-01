target=tetra_ribozyme.fa
output=blastdb
input=pdb_00805.fa

[[ -d $output ]] || mkdir -p $output
#makeblastdb -in $target -dbtype nucl -out $output/$target
 


blastn -query $input -out $output/$input.4 -db $output/$target  -word_size 7 -num_threads 20 -outfmt 4
blastn -query $input -out $output/$input.7 -db $output/$target  -word_size 7 -num_threads 20 -outfmt 7











