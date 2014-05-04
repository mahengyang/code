(ns hello.core
  (:gen-class)
  (:require [monger.core :as mg])
  (:require [monger.collection :as mc])
  (:require [clojure.set :as set])
  (:import [com.mongodb MongoOptions ServerAddress]
  		   [org.bson.types ObjectId]))

(mg/connect! { :host "192.168.56.254" :port 44001 })
(mg/set-db! (mg/get-db "zapya_api"))

(defn to-set [args]
	(if (set? args) args #{args}))

; (def data 
; 	(with-open [dbc (mc/find "uris")]
; 		(into [] (map #(do {(.get % "rid") (.get % "zid")}) dbc))))

(def data 
	(with-open [dbc (mc/find "test")]
		(into [] (map #(do {(.get % "item") (.get % "user")}) dbc))))

(def result 
	(apply merge-with 
		#(set/union (to-set %1) (to-set %2)) 
		data))

(defn sim [s1 s2]
	(/ (count (set/intersection s1 s2)) 
       (Math/sqrt (* (count s1) (count s2)))))

(defn calculate [result]
	(for [[master-key master-value] result :when (set? master-value)
		  [slave-key slave-value] result :when (and (< master-key slave-key) (set? slave-value))]
	  	(let [sim (sim master-value slave-value)]
	  		(if (> sim 0.1)
	  			(mc/insert "clj" {:r1 master-key :r2 slave-key :sim sim})))))

(defn -main [& args] 
	(println result))