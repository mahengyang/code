(ns hello.core
  (:gen-class))
(import java.lang.Math)

(defn hello [user]
	(println "you are:",(Math/sqrt user)))

(defn -main [& args]
  (hello 2))

