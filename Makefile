default: elm typescript

elm:
	/usr/local/bin/elm make lib/StateMachine.elm --output=dist/elm/StateMachine.js --optimize
	elm-test

elm-debug:
	/usr/local/bin/elm make lib/StateMachine.elm --output=dist/elm/StateMachine.js
	elm-test

typescript:
	npm install
	# for now typescript gets built with atom-typescript.

graph:
	# make graph (svg) of architecture
	node_modules/madge/bin/cli.js --image graph.svg ./dist

test:
	apm test
	elm-test
