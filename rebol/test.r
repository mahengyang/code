REBOL [
    Title: "REBOL Feedback GUI Form"
    Author: "Carl Sassenrath"
    Version: 2.0.0
    Needs: [view 2.7.6]
    Date: 15-Nov-2009 ; Original: 2-Apr-2001
]

fb-url: http://www.rebol.net/cgi-bin/fb-cgi.r

gui: layout [
    backeffect [gradient 0x1 220.220.240 120.120.120]
    across
    space 4x4
    style lab1 lab 100
    style lab2 lab 74
    style field1 field 196
    style field2 field 114

    lab1 "User name" f-name: field1
    lab2 "Product" f-product: field2 form system/product
    return 

    lab1 "Email address" f-email: field1
    lab2 "Version" f-version: field2 form system/version 
    return 

    lab1 "Date" f-date: field1 form now 
    lab2 "Urgency" f-urge: drop-down 114 data ["normal" "critical" "low" "note"]
    return 

    lab1 "Summary" f-summary: field 400
    return 

    lab1 "Description" f-description: area wrap 400x72
    return 

    lab1 "Example" f-code: area 400x72 font [name: font-fixed]
    return

    lab1
    btn-enter "Send" #"^S" [submit-fields]
    btn "Clear" [reset-fields show gui]
    btn-cancel #"^Q" [quit]
]

reset-fields: does [
    unfocus
    set-face f-name user-prefs/name
    set-face f-email any [system/user/email ""]
    set-face f-date now
    set-face f-version system/version
    set-face f-urge first f-urge/list-data
    clear-face f-summary
    clear-face f-description
    clear-face f-code
    focus f-summary
]

check-fields: does [
    foreach [field name] [
        f-version "version"
        f-summary "summary"
        f-description "description"
    ][
        if empty? get-face get field [
            alert reform ["The" name "field is required."]
            return false
        ]
    ]
    if all [
        not empty? get-face f-email
        not email? try [load get-face f-email]
    ][
        alert "The email address is not valid."
        return false
    ]
    true
]

get-fields: has [data] [
    data: make block! 10
    foreach face gui/pane [
        if face/var [
            repend data [face/var get-face face]
        ]
    ]
    data
]

submit-fields: has [data result] [
    unless check-fields [exit]
    result: send-server get-fields
    either result/1 = 'ok [
        alert "Feedback has been sent"
        quit
    ][
        alert reform ["Server error:" result]
    ]
]

send-server: func [data /local result] [
    data: compress mold/only data
    flash "Contacting server..."
    result: attempt [read/custom fb-url reduce ['post data]]
    unview
    any [attempt [load/all result] [failed connection]]
]

reset-fields
view center-face gui