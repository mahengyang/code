(ns ma)
(defmulti fill
	"fill a xml/html node"
	(fn [node value] (:tag node)))

(defmethod fill :div
	[node value]
	(assoc node :content [(str value)]))
(defmethod fill :input
	[node value]
	(assoc-in node [:attrs :value] (str value)))


