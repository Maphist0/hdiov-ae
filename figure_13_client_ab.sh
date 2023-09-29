#!/bin/bash
VM_IP=$1

## Concurrency
## How many rounds for 2^{ratio}, starting from 1
## set to 8 ==> 1, 2, 4, 8, 16, 32, 64, 128
END_RATIO=8

REQ_NUM=50000
#REQ_NUM=2000 ## If too slow, or ab timeout, uncomment this

echo "Using ping to warmup ..."
timeout 10 ping $VM_IP

CONCURRENT=1

for ratio in `seq 1 $END_RATIO`; do

	LOG=nginx_log_$CONCURRENT.txt
	echo "Output to log file: $LOG"

	__ab () {
		ab -n $REQ_NUM -c $CONCURRENT -k http://${VM_IP}/$1 2>&1 | tee -a $LOG
	}

	rm $LOG
	__ab 1kb.bin
	__ab 100kb.bin

	CONCURRENT=$((CONCURRENT * 2))
done

CONCURRENT=1

for ratio in `seq 1 $END_RATIO`; do
	LOG=nginx_log_$CONCURRENT.txt
	echo -n "$CONCURRENT,"
	cat $LOG | grep 'Requests per second' | cut -d ':' -f 2 | awk '{print $1}' | tr '\n' ','
	cat $LOG | grep 'Transfer rate' | cut -d ':' -f 2 | awk '{print $1}' | tr '\n' ','
	cat $LOG | grep 'Total:' | awk '{print $3}' | tr '\n' ','
	cat $LOG | grep 'Total:' | awk '{print $4}' | tr '\n' ','
	cat $LOG | grep 'Total:' | awk '{print $6}' | tr '\n' ','
	echo
	CONCURRENT=$((CONCURRENT * 2))
done
