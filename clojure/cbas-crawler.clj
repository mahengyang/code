(ns ma.test 
	(:require [net.cgrand.enlive-html :as enlive]
		 	  [clojure.java.io :as io])
	(:use [clojure.string :only (lower-case)])	
	(:import (java.net URL 
					   MalformedURLException)
			 java.util.concurrent.LinkedBlockingQueue))

(defn as-url 
	[url]
	(if (string? url)
		(URL. url)
		url))

(defn- links-from 
	[base-url html]
	(remove nil? 
		(for [link (enlive/select html [:a])]
			(when-let [href (-> link :attrs :href)]
				(try
					; 拼接url，href只是文件路径，base-url是主站
					(URL. (as-url base-url) href)
					(catch MalformedURLException e))))))
(defn- words-from
	[html]
	(let [chunks (-> html
					(enlive/at [:script] nil)
					(enlive/select [:body enlive/text-node]))]
		(->> chunks
			(mapcat (partial re-seq #"\w+"))
			(remove (partial re-matches #"\d+"))
			(map lower-case))))

(def url-queue (LinkedBlockingQueue.))
(def crawled-urls (atom #{}))
(def word-freqs (atom {}))

(declare get-url)
(def agents (set (repeatedly 25 #(agent {::t #'get-url :queue url-queue}))))

(declare run process handle-results)

(defn ^::blocking get-url
	[{:keys [^LinkedBlockingQueue queue] :as state}]
	(let [url (as-url (.take queue))]
		(try 
			(if (@crawled-urls url)
				state
				{:url url
				 :content (slurp url)
				 ::t #'process
				})
			(catch Exception e
				state)
			(finally (run *agent*)))))


(defn process
	[{:keys [url content]}]
	(try
		(let [html (enlive/html-resource (java.io.StringReader. content))]
			{::t #'handle-results
			 :url url
			 :links (links-from url html)
			 :words (reduce (fn [m word]
			 					(update-in m [word] (fnil inc 0)))
			 				{}
			 				(words-from html))})
		(finally (run *agent*))))

(defn ^::blocking handle-results
	[{:keys [url links words]}]
	(try
		(swap! crawled-urls conj url)
		(doseq [url links]
			(.put url-queue url))
		(swap! word-freqs (partial merge-with +) words)
		{::t #'get-url :queue url-queue}
		(finally (run *agent*))))

(defn paused? [agent] (::paused (meta agent)))

(defn run
	([] (doseq [a agents] (run a)))
	([a] 
		(when (agents a)
			(send a (fn [{transition ::t :as state}]
						(when-not (paused? *agent*)
							(let [dispatch-fn (if (-> transition meta ::blocking)
													send-off
													send)]
								(dispatch-fn *agent* transition)))
						state)))))

(defn pause
	([] (doseq [a agents] (pause a)))
	([a] (alter-meta! a assoc ::paused true)))

(defn restart 
	([] (doseq [a agents] (restart a)))
	([a] 
		(alter-meta! a dissoc ::paused)
		(run a)))

(defn test-crawler
	"reset all state assoceated with the crawler"
	[agent-count starting-url]
	(def agents (set (repeatedly agent-count
						#(agent {::t #'get-url :queue url-queue}))))
	(.clear url-queue)
	(swap! crawled-urls empty)
	(swap! word-freqs empty)
	(.add url-queue starting-url)
	(run)
	(Thread/sleep 10000)
	(pause)
	[(count @crawled-urls) (count url-queue)])