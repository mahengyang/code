;定义一个java类型SimpleCompass，实现Compass接口，并实现了java里Object的toString()方法
(defprotocol Compass
	(direction [c])
	(left [c])
	(right [c]))
(def directions [:north :east :south :west])
(defn turn 
	[base amount]
	(rem (+ base amount) (count directions)))
(defrecord SimpleCompass [bearing]
	Compass
	(direction [_] (directions bearing))
	(left [_] (SimpleCompass. (turn bearing 3)))
	(right [_] (SimpleCompass. (turn bearing 1)))
	Object
	(toString [this] (str "-" (direction this) "-")))
(def c (SimpleCompass. 0))
(println (.toString c))
(println (.toString (left c)))