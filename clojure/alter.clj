(def visitors (ref #{}))
(defn hello
	[username]
	(let [visitor (@visitors username)]
	(if visitor
		(str "you have aready in:" username)
		(do
			(dosync (alter visitors conj username))
			(str "new user:" username)))))
(println (hello "ma"))
(println (hello "ma"))