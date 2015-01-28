import java.util.Date

def dom = new XmlSlurper().parse(new File('e:/w/test.xml'))
for(listener in dom.Listener) {
	println "listener`s name: ${listener.@className}"
}