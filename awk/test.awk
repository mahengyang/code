BEGIN {
	FS=","

  taskCode = "ykfgsqb5wv67hqi0wbwi8hqktr00aejr"
}

{
  if(NR==1){
    print "������,�û���"
  }else if(NR>1) {
    print taskCode","$2
  }
}