(use 'clojure.string)

(def users [
	{:name "c", :plays 3,:loved 3}
	{:name "b", :plays 2,:loved 2}
	{:name "a", :plays 1,:loved 1}
	{:name "d", :plays 4,:loved 4}
])

(def my-sort-by (partial sort-by #(/ (:plays %) (:loved %))))

(println (join "\n" users))
(println "===================")
(println (join "\n" (my-sort-by users)))

(println "===================")

(defn columns [columns-names]
	(fn [row]
		(println (str "-- " columns-names))
		(vec (map row columns-names))))
(println (join "\n" (sort-by (columns [:name :loved :plays]) users)))

(println (map [:name] users))