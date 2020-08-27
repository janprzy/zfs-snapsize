zfs-snapsize
============
By default, it is not easily possible to recursively get the total size
of a ZFS snapshot across all datasets. Instead, the size of a snapshot
can only be read for individual datasets. This script simply adds up all
these numbers to convienently display the total size of the snapshot.

The reason for this odd behaviour is simple: While snapshots _can_ be
recursively created and deleted, they, unlike the datasets themselves,
do not acutally depend on one another. For instance, a snapshot can be
deleted on one dataset but kept on a descendant of that dataset - that
is not possible with datasets.

Only the space unique to a dataset is marked as "used", the rest is
lumped into "refer". Consequently, only the "used" space will be freed
up when deleting the dataset. In the case of normal datasets, whose
children can not exist without the parent, the "used" column contains
the space used by all children. However, this is not the case with
snapshot. Since snapshots don't contain or own their siblings on
subordinate datasets, their "used space" does not include the space
used by the apparent descendants.

Command Usage
--------------
    zfs-snapsize.sh [flags] filesystem
    -h: Human-readable output - SI unit prefixes
    -u: Display this screen

Example output
--------------
    zroot@2020-07-19_00-00-00                 394M
    zroot@2020-07-26_00-00-00                 396M
    zroot@2020-08-02_00-00-00                 396M
    zroot@2020-08-09_00-00-00                 173M
    zroot@2020-08-16_00-00-00                 481M
    zroot@2020-08-22_10-23-44                21.5M
    zroot@2020-08-23_00-00-00                13.7M
    zroot@2020-08-27_08-19-10                 199M
