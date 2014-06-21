(require '[net.cgrand.enlive-html :as enlive]
		 '[clojure.java.io :as io])
(import '(java.net URL))
; 文件中保存着youku上的视频的url，抓取网页中的tags
(defn download [url parser]
	(if-let [page (try 
					(enlive/html-resource (URL. url)) 
					(catch java.io.FileNotFoundException e))]
		[url (parser page)]))

(defn parse-youku-tags [page]
	(map enlive/text 
		(enlive/select page [[:div.crumbs] :a])))

(defn urls [file-name my-parse]
	(with-open [file (io/reader file-name)]
		(doall (map #(download % my-parse) (line-seq file)))))

(defn urls-pmap [file-name my-parse]
	(with-open [file (io/reader file-name)]
		(doall (pmap #(download % my-parse) (line-seq file)))))

; (def result 
; 	(urls 
; 		"/media/puffin/mycode/gnu-parallel/a" 
; 		parse-youku-tags))