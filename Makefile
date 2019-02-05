compile:
	mkdir -p build
	scalac -classpath experiment.jar:lib/openmodbat-3.2.jar -sourcepath src -deprecation -verbose -d build src/model/*/*.scala
clean:
	rm -f build
run-simple:
	time scala -classpath build lib/openmodbat-3.2.jar \
		-s=10 \
		-n=5 \
		--abort-probability=0.02 \
		model.simple.SimpleListModel
run-complex:
	time scala -classpath . openmodbat-3.2.jar \
		-s=5 \
		-n=1000 \
		--abort-probability=0.02 \
		model.complex.LinkedListModel
#example: make show-trace FILE=<file name>
show-trace:
	if [ "`echo ${FILE} | grep .err`" = "" ]
	then
		FILE1="${FILE}.err"
	else
		FILE1="${FILE}"
	fi
	cat $FILE1 | \
		sed -e 's/^\([a-z._A-Z]*Exception\)$/[91m\1[0m/' \
		-e 's/^\(.WARNING.\|.ERROR.\)/[31m\1[0m/' \
		-e 's/\([a-z/._A-Z:0-9]*\): *\([^:]*\): \(.*\)$/[40m[93m\1[0m:\2: [40m[97m\3[0m/'
