(use 'clojure.java.io 'clojure.set)

;如果原始数据读入时用map接收，下面就可以用merge-with
(def data 
	(with-open [rdr (reader "/tmp/uris.test")]
		(into [] (map 
					#(if % 
						(let [ [k v] (.split % ",")] {(Long/parseLong k) v})) 
					(line-seq rdr)))))
(defn to-set [set]
	(if (set? set) set #{set}))
;使用apply转变
(def result (apply merge-with 
	#(union
		(to-set %1) 
		(to-set %2)) 
	data))

(defn sim [s1 s2]
	(let [ s (/ 
				(count (intersection s1 s2)) 
				(Math/sqrt (* (count s1) (count s2))))]
	(when (> s 0.1)
		s)))

; 使用for循环计算任意两个item之间的相似度
(defn cal-for [result]
	(doall (for [[k1 v1] result 
			:when (set? v1)
		  [k2 v2] result 
		  	:when (and (< k1 k2) (set? v2))]
			[k1 k2 (sim  v1 v2)])))

; 使用pmap并行计算每个item与其它所有item之间的相似度
(defn cal-one [[k1 v1] result]
	(when (set? v1) 
		(doall (for [[k2 v2] result
				:when (and (set? v2) (< k2 k1))]
			(if-let [s (sim v1 v2)]
				(when (> s 0.1) 
					[k1 k2 s]))))))

(defn cal-pmap [result] 
	(doall (map #(cal-one % result) result)))