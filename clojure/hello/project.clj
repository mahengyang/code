(defproject hello "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]
  				[org.clojure/clojure-contrib "1.2.0"]
  				[mysql/mysql-connector-java "5.1.6"]
          [com.novemberain/monger "1.7.0"]]
  :main hello.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
