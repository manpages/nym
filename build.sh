for package in nym nym:daemon nym:core nym:node nym:persist ; do dub build $package; done
mv -vt bin/ nym* *.a