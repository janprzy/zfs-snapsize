#!/bin/sh
fs=$1
human_readable=$2 # TODO: Proper CLI flag

if [ -z $human_readable ]
then
	human_readable=1;
fi


# Format a number with an SI prefix
# $1: The number
# $2: Amount of significant digits
si-format()
{
	# log(n)/log(10) is the 10th logarithm of the number. After rounding it down with int(), we get the number of digits in n
	# Therefore, length(n)/3 gives us a factor f, which corresponds to the next smallest multiple of 1000, e.g.:
	# 1; 10; 100             => f=0
	# 1,000; 10,000; 100,000 => f=1
	# 1,000,000; 10,000,000  => f=2
	#
	# Then, n is divided by 1000^f, giving us the first 1-3 digits.
	# The printf call used here will output s significant digits.
	#
	# Finally, an SI-prefix corresponding to f is chosen.
	#
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

# List of all snapshots of all descendant datasets, including space used by them. This will later be needed.
# 'sed' cuts the parts after the @ off, in case a snapshot was provided
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
