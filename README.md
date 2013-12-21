daily-backup-snapshot-script
============================

The original (old) script is also on my web site: http://rhobbs.co.uk/beh

This "makeSnapshots.sh" script enables you to go back in time to find an old or recent version of an file or directory that was deleted or modified at some point by providing you with daily, weekly, monthly and yearly snapshots.

This script is designed to run once per day, it can write snapshots to a separate directory (local or NFS) or via the rsync protocol to a remote server if you like and for the first time it runs it initially makes an entire copy of your original data which it then makes a copy of and updates daily.

