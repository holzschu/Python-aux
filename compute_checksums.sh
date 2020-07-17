for framework in libpng libffi libzmq openblas
do
   echo $framework
   rm -f $framework.xcframework.zip
   zip -rq $framework.xcframework.zip $framework.xcframework
   swift package compute-checksum $framework.xcframework.zip
done

