bin/nym add dummy
for x in {1..10000}; do 
  time bin/nym info dummy seqtest "$x" &
done
