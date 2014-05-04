(import '(java.util.concurrent Executors))

(def *pool* (Executors/newFixedThreadPool
	(+ 2 (.availableProcessors (Runtime/getRuntime)))))

(defn dothreads! 
	[f & {thread-count :threads
		  exec-count :times
		  :or {thread-count 1 exec-count 1}}]
	(dotimes [t thread-count]
		(.submit *pool* #(dotimes [_ exec-count] (f)))))

(def initial-board
	[[:- :k :-]
	 [:- :- :-]
	 [:- :K :-]])

; 返回9个ref，分别指向每一个位置
(defn board-map [f bd]
	(vec (map #(vec (for [s %1]  (f s))) bd)))

(defn reset! 
	"resets the board state"
	[]
	(def board (board-map ref initial-board))
	(def to-move (ref [[:K [2 1]] [:k [0 1]]]))
	(def num-moves (ref 0)))

(def matrix [
	[1 2 3]
	[4 5 6]
	[7 8 9]])

(defn neighbors
	([size yx] (neighbors [[-1 0] [1 0] [0 -1] [0 1]] size yx))
	([deltas size yx]
		(filter (fn [new-yx]
			(every? #(< -1 % size) new-yx))
		(map #(map + yx %) deltas))))

(def king-moves (partial neighbors 
						 [
						  [-1 -1]
						  [-1 0]
						  [-1 1]
						  [0 -1]
						  [0 1]
						  [1 -1]
						  [1 0]
						  [1 1]] 
						 3))

(defn good-move? [to enemy-sq]
	(when (not= to enemy-sq) to))
;(choose-move [[:K [2 1]] [:k [0 1]]])
(defn choose-move [[[mover mpos] [_ enemy-pos]]]
	[mover (some #(good-move? % enemy-pos)
					(shuffle (king-moves mpos)))])

(reset!)
(take 5 (repeatedly #(choose-move @to-move)))

(defn place [from to] to)

(defn move-piece [[piece dest] [[_ src] _]]
	(alter (get-in board dest) place piece)
	(alter (get-in board src) place :-)
	(alter num-moves inc))

(defn update-to-move [move]
	(alter to-move #(vector (second %) move)))

(defn make-move []
	(dosync 
		(let [move (choose-move @to-move)]
			(move-piece move @to-move)
			(update-to-move move))))

(defn go [move-fn threads times] 
	(dothreads! move-fn :threads threads :times times))

(go make-move 100 100)
(board-map #(dosync (deref %)) board)