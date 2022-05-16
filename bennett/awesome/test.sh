TMP=$(mktemp -d)

trap "rm -r $TMP" SIGINT SIGTERM EXIT SIGKILL
trap '[ -n "$(jobs -p)" ] && kill $(jobs -p) 2>/dev/null' SIGINT SIGTERM EXIT SIGKILL

ln -s `pwd` $TMP/awesome

exec 6>$TMP/display

#Xephyr -displayfd 6 -s 10000 -ac -noreset -screen 1280x720 > $LOG 2> $LOG_ERROR &
Xephyr -displayfd 6 -s 10000 -ac -noreset -screen 1280x720 >/dev/null 2>&1 &

while [ ! `cat $TMP/display` ]; do sleep 0.1; done
exec 6>&-

DP_NUM=`cat $TMP/display`
DP=:$DP_NUM

export DEBUG=true
export XDG_CONFIG_HOME=$TMP
export DISPLAY=$DP.0

awesome -c $TMP/awesome/rc.lua &
WM_PID=$!

printf "\033[1;31mSTARTING\033[1;0m\n"

# Debounce interval in seconds
interval=1
(( limit = `date +"%s"` + interval ))
inotifywait -r -m -e close_write --exclude 'index.lock|test.sh|.git' . 2>/dev/null | while read dir events f
do
	if (( limit < `date +"%s"` )); then
		(( limit = `date +"%s"` + interval ))
		printf "\033[1;31mRELOADING: \033[1;0m$f\n"
		kill -HUP $WM_PID
	else
		printf "           $f\n"
	fi
done
