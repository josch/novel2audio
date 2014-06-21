#!/bin/sh

NUM=0
QUEUE=""
MAX_NPROC=12

while read CMD; do
    sh -c "$CMD" &

    PID=$!
    QUEUE="$QUEUE $PID"
    NUM=$(($NUM+1))

    # if enough processes were created
    while [ $NUM -ge $MAX_NPROC ]; do
        # check whether any process finished
        for PID in $QUEUE; do
            if [ ! -d /proc/$PID ]; then
                TMPQUEUE=$QUEUE
                QUEUE=""
                NUM=0
                # rebuild new queue from processes
                # that are still alive
                for PID in $TMPQUEUE; do
                    if [ -d /proc/$PID  ]; then
                        QUEUE="$QUEUE $PID"
                        NUM=$(($NUM+1))
                    fi
                done
                break
            fi
        done
        sleep 0.5
    done
done
wait
