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


;=================================

(ns com.ociweb.bank)
 
; Assume the only account data that can change is its balance.
(defstruct account-struct :id :owner :balance-ref)
 
; We need to be able to add and delete accounts to and from a map.
; We want it to be sorted so we can easily
; find the highest account number
; for the purpose of assigning the next one.
(def account-map-ref (ref (sorted-map)))

(defn open-account
  "creates a new account, stores it in the account map and returns it"
  [owner]
  (dosync ; required because a Ref is being changed
    (let [account-map @account-map-ref
          last-entry (last account-map)
          ; The id for the new account is one higher than the last one.
          id (if last-entry (inc (key last-entry)) 1)
          ; Create the new account with a zero starting balance.
          account (struct account-struct id owner (ref 0))]
      ; Add the new account to the map of accounts.
      (alter account-map-ref assoc id account)
      ; Return the account that was just created.
      account)))

(defn deposit [account amount]
  "adds money to an account; can be a negative amount"
  (dosync ; required because a Ref is being changed
    (Thread/sleep 50) ; simulate a long-running operation
    (let [owner (account :owner)
          balance-ref (account :balance-ref)
          type (if (pos? amount) "deposit" "withdraw")
          direction (if (pos? amount) "to" "from")
          abs-amount (Math/abs amount)]
      (if (>= (+ @balance-ref amount) 0) ; sufficient balance?
        (do
          (alter balance-ref + amount)
          (println (str type "ing") abs-amount direction owner))
        (throw (IllegalArgumentException.
                 (str "insufficient balance for " owner
                      " to withdraw " abs-amount)))))))
 
(defn withdraw
  "removes money from an account"
  [account amount]
  ; A withdrawal is like a negative deposit.
  (deposit account (- amount)))

(defn transfer [from-account to-account amount]
  (dosync
    (println "transferring" amount
             "from" (from-account :owner)
             "to" (to-account :owner))
    (withdraw from-account amount)
    (deposit to-account amount)))

(defn- report-1 ; a private function
  "prints information about a single account"
  [account]
  ; This assumes it is being called from within
  ; the transaction started in report.
  (let [balance-ref (account :balance-ref)]
    (println "balance for" (account :owner) "is" @balance-ref)))
 
(defn report
  "prints information about any number of accounts"
  [& accounts]
  (dosync (doseq [account accounts] (report-1 account))))


(let [a1 (open-account "Mark")
      a2 (open-account "Tami")
      thread (Thread. #(transfer a1 a2 50))]
  (try
    (deposit a1 100)
    (deposit a2 200)
 
    ; There are sufficient funds in Mark's account at this point
    ; to transfer $50 to Tami's account.
    (.start thread) ; will sleep in deposit function twice!
 
    ; Unfortunately, due to the time it takes to complete the transfer
    ; (simulated with sleep calls), the next call will complete first.
    (withdraw a1 75)
 
    ; Now there are insufficient funds in Mark's account
    ; to complete the transfer.
 
    (.join thread) ; wait for thread to finish
    (report a1 a2)
    (catch IllegalArgumentException e
      (println (.getMessage e) "in main thread"))))


