#!/bin/sh
fs=$1
human_readable=$2

# Format a number with an SI prefix
# $1: The number
# $2: Number of significant digits
si-format()
{
	awk -v n="$1" -v s="$2" '
        	BEGIN { f=int( (log(n)/log(10)) / 3)
        	printf("%." s "g"), n/(1000^f)
        	printf substr("BKMGTP", f+1, 1) "\n"
        	} '
}

# List all snapshots at the root level. If $fs already is a snapshot, that will be the entire list.
# $pool will be set to the parent of all snapshots.
echo $fs | grep @ > /dev/null # Returns 0 if it found something, i.e. if $fs contains an @
if [ $? == 0 ]
then
	snaplist_root="$fs"
	pool="$(echo $fs | sed s/@.*//g)"
else
	snaplist_root="$(zfs list -H -t snap -d 1 -o name "$fs")"
	pool=$fs
fi

# List of all snapshots of all descendant datasets, including their used space. This will later be used.
# sed cuts the parts after the @ off, in case a single snapshot was provided
snaplist_full="$(zfs list -Hrp -t snap -o name,used "$pool")"

# Iterate over the snapshots and calculate their respective size
for i in $snaplist_root
do
	# 1. Echo the list of all snapshots of all descendants for further processing
	# 2. Grep one snapshot (of all datasets)
	#    'sed' inserts a wildcard before the @ to make sure grep selects sub-datasets as well.
	#    '~' is used as the regex separator because $fs may contain '/'
	# 3. Get the last field of every line, use whitespace as the separator (-w)
	#    It is not possible to select the last field directly, so the entire string is reversed before being fed into 'cut'
	# 4. Concatenate the lines with "+" as a the separator, so 'bc' undestands what to do
	# 5. Add the numbers to obtain the combined size
	size=$(echo "$snaplist_full" | grep -G "$(echo "$i" | sed "s~$pool@~$pool\.\*@~g")" | rev | cut -wf1 | rev | paste -sd+ - | bc)

	if [ $human_readable -eq 1 ]
	then
		echo "$i" "$(si-format $size 3)"
	else
		echo "$i" $size
	fi
done
