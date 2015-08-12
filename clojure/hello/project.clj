(defproject hello "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
  			         [org.clojure/clojure-contrib "1.2.0"]
  			         [mysql/mysql-connector-java "5.1.25"]
                 [com.novemberain/monger "1.7.0"]
                 [enlive "1.1.5"]
                 [org.clojure/java.jdbc "0.3.3"]
                 [ring/ring-core "1.3.0"]
                 [ring/ring-jetty-adapter "1.3.0"]]
  :dev-dependencies [[lein-ring "0.8.11"]]
  :main hello.core
  :target-path "target/%s"
  :profiles {:dev {:plugins [[cider/cider-nrepl "0.9.1"]]}})
