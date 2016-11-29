BEGIN {
	FS="	"
}

NR>1{
	if(NR == 2) {
		print "insert ignore into hyip_o2o_baoquan (user_id,baoquan_number,baoquan_biz_id, baoquan_recycle_biz_desc,`status`,user_regist_time,update_time,create_time) values "
	}
	gsub(/'/,"",$1)
	row = ("(" $1 ", 1000, '" $1 "_new_user'" ", '扫码购专用券失效'" ", 1, " $2 ", now(), now()"")")
	seperate = ","
	if(NR % 2000 == 0) {
		seperate = ";"
	}
	print row,seperate
	tmpp[NR] = row
	if(NR % 2000 == 0) {
		print "insert ignore into hyip_o2o_baoquan (user_id,baoquan_number,baoquan_biz_id, baoquan_recycle_biz_desc,`status`,user_regist_time,update_time,create_time) values "
	}
}
