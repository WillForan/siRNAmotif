#print 
# score	motif	position	std	background(m0,m1,m2)		#sequnces	#motifs	iteration
awk 'BEGIN{run="";it=0; back=" ";motif=" ";source=""}{  
    if(/too few/){ next} 
    if(/^==/){run=substr($0,5); next} 
    if(/^=> \.\./){
     it=0; 
     back=substr($0, match($0,"back")+10,3);
     num=substr($0, match($0,"numM")+10,2);
     
     startpos=match($0,"fas/")+4;
     stoppos=match($0,".fa ");
     source=substr($0,startpos, stoppos-startpos); 
     next
    }
    if(/^=>/){
    	it=substr($0, match($0,"[0-9]"),1 ); 
	startpos=match($0,"/")+1;
	source= substr($0,startpos, match($0,".fa")-startpos); 
	next}
    print $0 "\t" back "\t" num "\t" run "\t" it "\t" source }' $1 |
sed 's/=//g;s/Control Run /CR/g';
