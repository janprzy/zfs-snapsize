zfs-snapsize
============
_Get the total size of a ZFS snapshot across all descendant datasets_

By default, it is not easily possible to recursively get the total size
of a ZFS snapshot across all datasets. Instead, the size of a snapshot
can only be read for individual datasets. This script simply adds up all
these numbers to convienently display the total size of the snapshot.
