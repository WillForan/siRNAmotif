awk 'BEGIN{run="";it=0; back=" ";motif=" "}{  
    if(/too few/){ next} 
    if(/^==/){run=substr($0,5); next} 
    if(/^=> \.\./){
     it=0; 
     back=substr($0, match($0,"back")+10,3);
     num=substr($0, match($0,"numM")+10,2);
     next
    }
    if(/^=>/){it=substr($0, match($0,"[0-9]"),1 ); next}
    print $0 "\t" back "\t" num "\t" run "\t" it}' $1 |
sed 's/=//g;s/Control Run /CR/g';
