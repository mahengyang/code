BEGIN {
	FS="\t"

}

{
	if(NR>1) {
		sub(/ms/,"",$7)
		split($5,a,/\//)
		api=""
		if(match($5,/api\/get\//)||match($5,/api\/load\//)){
			api=a[2]"/"a[3]"/"a[4]
		}else if(match($5,/v11/)){
			api=a[2]"/"a[3]"/"a[4]"/"a[5]
		}else{
			api=a[2]"/"a[3]
		}
		print $1,$2,api,$7
	}
}