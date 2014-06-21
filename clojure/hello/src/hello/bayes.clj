(ns bayes
  (:require [clojure.java.jdbc :as jdbc]))

(def mysql-db {:subprotocol "mysql"
               :subname "//192.168.56.254:3306/openroom"
               :user "root"
               :password "."})

(def N 100000)

; (defn test [name]
; 	(let [word name
; 		   result []
; 		   start 0]
; 		  (println (str word " " result " " start))
; 		  (if (< (.length name) 2)
; 		  		name 
; 		  		(recur 
; 		  			(.substring name start (.length name)) 
; 		  			(conj result (.substring name 0 1))
; 		  			(inc start)))))

(defn extraction [name]
	(let [length (.length name)
		  start-index (if (< length 4) 1 2)
		  nm (.substring name start-index length)]
		  (seq nm)))


(def data (jdbc/query 
				mysql-db 
				["select name,gender from openroom.recorder_copy limit ?" N]
    			:as-arrays? true
    			:row-fn #(let [[name gender] %1] 
        						(if (not= 
        							  (count (.getBytes name))
        							  (.length name))
        							(let [words (extraction name)]
        								(if (< (count words) 2)
        									[(first words) gender]
        									[(first words) gender (second words) gender]))))))

(defn my-group-by [v,f]
  (let [group (group-by f v)
        result (reduce into 
                  (map #(let [[key,value] %1] 
                          {key (count value)}) 
                        group))]
        result))
; 统计词频
(defn group [[_ & record]]
	(let [word-count (count record)
        gender-group (my-group-by record 
                        #(let [[name,gender] %1] gender))
        name-group (my-group-by record 
                        #(let [[name,gender] %1] (str name gender)))]
		(def sample-number word-count)
    (def gender-map gender-group) 
    (def word-map name-group)))

(group (filter #(not= % nil) data))

(defn p [word gender]
  (if-let [word-count (word-map (str word gender))]
    (let [gender-count (gender-map gender)
          p-w-g (/ word-count gender-count)
          p-g (/ gender-count sample-number)]
          (* p-w-g p-g))
    (/ 1 sample-number)))

(defn bayes [word]
  (let [pf (p word "F")
        pm (p word "M")]
    {:F pf :M pm}))

(defn cal [name]
  (let [probability (map bayes (extraction name))
        pf (reduce * (map :F probability))
        pm (reduce * (map :M probability))]
        (if (< pf pm)
            ["男" pm pf]
            ["女" pf pm])))