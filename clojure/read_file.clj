(use 'clojure.java.io 'clojure.set)
;把文件的每一行存入vector中
(def data (with-open [rdr (reader "/tmp/test.txt")]
		(into [] (line-seq rdr))))
(println "result is:" data)

;一边读文件，一边解析每一行到一个vector中，最后存入vector中返回
(def data (with-open [rdr (reader "/tmp/test.txt")]
		(into [] (map 
					#(if % 
						(let [ [k v] (.split % ",") ] [k v])) 
					(line-seq rdr)))))
(println "原始数据：" data)
(def tmp_data (group-by #(first %) data))
(println "按第一个元素group by之后：" tmp_data)
(def result (for [ [k values] tmp_data]
		[k (into #{} (map second values))]))
(println "把values转为列表" result)

;如果原始数据读入时用map接收，下面就可以用merge-with
(def data (with-open [rdr (reader "/tmp/test.txt")]
		(into [] (map 
					#(if % 
						(let [ [k v] (.split % ",")] {(Integer/parseInt k) v})) 
					(line-seq rdr)))))
;也可以使用apply转变
(def result (apply merge-with 
	#(union
		(if (set? %1) %1 #{%1}) 
		(if (set? %2) %2 #{%2})) 
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
(println pair)

