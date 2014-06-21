(ns hello.macro)

(defmacro first [data field]
	`(group-by (fn [x] (let [[name,gender] x] ~`field)) ~data))

(defn mygroup-by [v, field]
	(group-by 
		#(nth %1 (.indexOf ["name" "gender"] field)) v))