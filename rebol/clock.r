REBOL [
    Title: "Digital Clock"
    Version: 1.3.3
    Author: "Carl Sassenrath"
    Purpose: {A simple digital clock.}
]

f: layout [
    origin 0
    b: banner 140x32 rate 1 
        effect [gradient 0x1 150.0.150 150.0.50 invert]
        feel [engage: func [f a e] [set-face b now/time]]
]

view f