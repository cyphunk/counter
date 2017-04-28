#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/pinsinit.sh
# following values defined in countinit now
# COUNTSTART=1
# COUNTUNTIL=660
# ENDWITH="FIN"
. $DIR/countinit.sh

# COUNTSTART=108
# COUNTUNTIL=110


# defaults:
COUNTSTART="${COUNTSTART:-1}"
COUNTUNTIL="${COUNTUNTIL:-630}"
SECONDSBETWEENTICK="${SECONDSBETWEENTICK:-1}"
ENDWITH="${ENDWITH:-}"
ENDSECONDS="${ENDSECONDS:-3}"

STATEFILE="$DIR/state.txt"
# touch $STATEFILE
# ALWAYS START WITH PAUSE

while [ 1 ]; do
    echo "starting from BLANK"
    print3patterns $(string2patterns "   ")
    if [ "$DEBUG" != "1" ]; then
        echo "BLANK" > $STATEFILE
    else
        echo "GO" > $STATEFILE
    fi
    # Wait for user to go past blank
    while [ "$(cat $STATEFILE)" != "GO" ]; do
        sleep 0.01
    done

    # SETUP INITIAL STATE
    . "$DIR/countinit.sh"
    i=$COUNTSTART
    if [ "$DEBUG" != "1" ]; then
        echo "PAUSE" > $STATEFILE
    else
        echo "GO" > $STATEFILE
    fi
    next3segpatterns=$(string2patterns "$(printf '%3d' $i)")
    starttick=$(date +%s)
    lasttick=$starttick


    while [ $i -le $COUNTUNTIL ]; do
        # wait for a second to pass
        # ineffect this also waits for start of first second before first print
        while [ "$(($(date +%s)-($SECONDSBETWEENTICK-1)))" -le "$lasttick" ]; do
            sleep 0.01
        done
        # show pre-prepared patters
        print3patterns $next3segpatterns
        if [ "$DEBUG" == "1" ]; then
            echo "tick: $i"
        fi
        # prepare next patterns before wait
        lasttick=$(date +%s)
        i=$(($i+1))
        next3segpatterns=$(string2patterns "$(printf '%3d' $i)")
        # check state
        CURSTATE=$(cat $STATEFILE)
        if [ "$CURSTATE" == "PAUSE" ]; then
            while [ 1 ]; do
                sleep 0.1
                CURSTATE=$(cat $STATEFILE)
                lasttick=$(date +%s)
                if [ "$CURSTATE" != "PAUSE" ]; then
                    break
                fi
            done
        fi
        if [ "$CURSTATE" == "RESET" ]; then
            # check config values incase changed via web
            break
        fi
        # if it is go we just keep going
        sleep 0.01
    done



    if [ $i -ge $COUNTUNTIL ]; then
        sleep 1
        echo "show end"

        #finish animation?
        print3patterns $(string2patterns "$(printf '%3s' $ENDWITH)")
        sleep $ENDSECONDS
        print3patterns $(string2patterns "   ")

        # wait for reset before continuing
        #while [ "$(cat $STATEFILE)" != "RESET" ]; do
        #    sleep 0.01
        #done
        # or instead (because init state is blank already)
        # just let reset happen
    fi
    # reset:
    # start again

done
# DEBUG LOOP
#sleep 5
#$0
#/DEBUG LOOP

#clean_up
