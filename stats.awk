BEGIN{min=9**9**9; max=-9**9**9;}
{ 
   if($1>max){max=$1} 
   if($1<min){min=$1} 
   sum += $1; sumsq += $1*$1;
}
END { printf "Mean: %f, Std: %f\nMin: %f, Max: %f\n", sum/NR, sqrt(sumsq/NR (sum/NR)^2), min, max }
