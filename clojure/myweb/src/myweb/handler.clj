(ns myweb.handler
  (:use [hiccup core page form])
  (:require [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]))

;; 主页面
(defn main-page [result]
  (html5 
  	  [:head
  	    [:title "演讲评分"]
  	    (include-css "index.css")]
  	  [:body 
  	    [:h1 "演讲评分"]
  	    [:hr]
  	    [:h2 result]
  	    (form-to [:post "/comment/add"]
  	      "演讲者：" 
  	      [:select (select-options ["刘云" "刘金龙"])]
  	      "&nbsp;评分者：" 
  	      [:select (select-options ["2014-1-1" "2014-1-2"])]
  	      [:p] 
  	      "是否有用？（10分）" 
  	      (text-field {:size 5} "score1" )
  	      [:p] 
  	      "收获" 
  	      [:p] 
  	      (text-area {:cols 70 :rows 3} "gain")
  	      [:p] 
  	      (submit-button "使劲点一下"))]))

(defroutes app-routes
  (GET "/" [] (main-page ""))
  (POST "/comment/add" {p :params} (main-page "成功"))
  (route/resources "/")
  (route/not-found "Not Found"))

(def app
  (handler/site app-routes))
