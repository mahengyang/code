(use 'clojure.java.io 'clojure.set)

;如果原始数据读入时用map接收，下面就可以用merge-with
(def data 
	(with-open [rdr (reader "/tmp/test.txt")]
		(into [] (map 
					#(if % 
						(let [ [k v] (.split % ",")] {(Integer/parseInt k) v})) 
					(line-seq rdr)))))
(defn to-set [set]
	(if (set? set) set #{set}))
;使用apply转变
(def result (apply merge-with 
	#(union
		(to-set %1) 
		(to-set %2)) 
	data))
(println "使用apply和merge-with：" result)

(defn sim [s1 s2]
	(/ 
		(count (intersection s1 s2)) 
		(Math/sqrt (* (count s1) (count s2)))))

(def pair 
	(for [s1 result 
		  s2 result] 
		(let [[k1 v1] s1
		 	  [k2 v2] s2 ]
			(if (and (< k1 k2) (every? set? [v1 v2]))
				[k1 k2 (sim  v1 v2)]))))
(println "item-cf结果：" pair)

