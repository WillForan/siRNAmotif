function runDECOD {
    width=$4;
    if [ ! -d output/$width ];then 
	mkdir output/$width
    fi
    echo -e "width\t$width\npos\t$1\nneg\t$2\noutput\t${3}_$width\n";
    echo "java -jar DECOD-20110613.jar -nogui -pos $1  -neg $2 -o output/$width/$3 -c 4 -w $width"
    java -jar DECOD-20110613.jar -nogui -pos $1  -neg $2 -o output/$width/$3 -c 4 -w $width
}
