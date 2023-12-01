$name=$ARGV[0];
@name=split /Aligned.toTranscriptome/,$name;
system("mv $name $name[0].sam");


