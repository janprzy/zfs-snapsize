zfs-snapsize
============
By default, it is not easily possible to recursively determine the total
space used by a ZFS snapshot. After taking a recursive snapshot, the
used space can be displayed on each individual filesystem, but not all at
once.

The reason for this odd behaviour is simple: While snapshots _can_ be
recursively created and deleted, they, unlike the filesystems
themselves, do not acutally depend on one another. Technically, what
looks like one big snapshot across a ZFS hierachy, is instead a
collection of independant snapshots with the same name.
For instance, a snapshot can be deleted on one dataset but kept on a
descendant - that is not possible with datasets themselves.

Consequently, the "used" space of a snapshot does not include the space
used by its incarnations on descendant filesystems. A snapshot, unlike a
filesystem, does not own or contain its seeming descendants.

This script aims to solve the described issue by simply adding up the
space used by all incarnations of a snapshot, giving us the total size.
This will be the unique, deduplicated size of a snapshot, i.e. the space
that is freed up when deleting it. Adding up the sizes this script
returns for individual snapshots will *not* result in the space used by
_all_ snapshots, that information is stored in the `usedbysnapshots`
property.

Command Usage
-------------
    znapsize.sh [flags] filesystem
    -h: Human-readable output - SI unit prefixes
    -u: Display the help screen

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

Installation
-----------
`install.sh` installs `znapsize.sh` to `/usr/local/bin/znapsize` and sets
the appropriate permissions (+x to make it executable). You will be asked
to overwrite if it already exists.
