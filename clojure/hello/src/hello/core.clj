(ns hello.core
  (:gen-class)
  (:import (javax.swing
             JList 
             JLabel 
             JFrame 
             JPanel 
             JScrollPane 
             JButton 
             JMenuBar
             JMenu
             JMenuItem
             JComponent
             ImageIcon
             InputMap
             KeyStroke
             AbstractAction)
           (java.awt.event ActionEvent
                           ActionListener
                           KeyEvent
                           MouseAdapter
                           MouseMotionListener)
           (java.awt Dimension Graphics Color)
           java.awt.image.BufferedImage
           java.net.URL))
(def button 
  (doto (JButton. "click me")
    (.addActionListener 
      (proxy [ActionListener] []
        (actionPerformed [e] 
                         (println "you press"))))))

(def myAction
  (proxy [AbstractAction ActionListener] []
    (actionPerformed [e] (println "action performed"))))

(def panel 
  (doto (JPanel.)
    (.setPreferredSize (Dimension. 400 200))
    (.addMouseListener 
      (proxy [MouseAdapter] []
        (mousePressed [e] 
                      (println "mouse clicked"))
        (mouseReleased [e] 
                       '())))
    (.. (getInputMap) (put (KeyStroke/getKeyStroke "F2") "this is F2"))
    (.. (getActionMap) (put "action" myAction))))

(defn window
  (doto (JFrame. "hello world")
    (.setDefaultCloseOperation JFrame/EXIT_ON_CLOSE)
    (.setSize 400 400) 
    (.add panel)
    (.pack)
    (.setVisible true)))





