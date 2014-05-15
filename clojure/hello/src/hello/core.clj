(ns hello.core
  (:gen-class)
  (:refer-clojure :exclude [select find sort])
  (:import [com.mongodb MongoOptions ServerAddress]
  		   [org.bson.types ObjectId])
  (:require [monger.core :as mg]
  			[monger.collection :as mc] 
  			[clojure.set :as set]
  			[monger.query :refer :all]))

(mg/connect! { :host "192.168.56.254" :port 44001 })
(mg/set-db! (mg/get-db "zapya_api"))

(defn to-set [args]
	(if (set? args) args #{args}))

(defn read-batch [coll offset batch]
	(with-collection coll
		(find {})
		(fields [:_id :classify])
		(skip offset)
		(limit batch)))

(defn destr [a-seq]
	(map
		#(let [{app-name :_id, tags :classify} %1] 
			(if (> (count tags) 0)
				[app-name (into #{} tags)]))
		a-seq))

(def data 
	(let [coll "ma.app.info"
		batch 10
		record-number (mc/count coll)
		offset (range 0 100 batch)]
		(apply concat 
			(pmap destr 
				(pmap #(read-batch coll % batch) offset)))))

(defn sim [s1 s2]
	(/ (count (set/intersection s1 s2)) 
       (Math/sqrt (* (count s1) (count s2)))))

(defn calculate [result]
	(for [[master-key master-value] result 
			:when (not (nil? master-key))
		  [slave-key slave-value] result 
			:when (and 
		  			(not (nil? slave-key)) 
		  			(> 0 (.compareTo master-key slave-key)))]
  		 (let [sim (sim master-value slave-value)]
  			(if (> sim 0.1)
  				(do (.start (Thread. #(do (Thread/sleep 10)))))))))

;(println (.getName (Thread/currentThread ))
(def total-time (time (dorun (calculate data))))

(defn -main [& args] 
	(println "main"))