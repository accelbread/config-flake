# Managing kernel patches

## Getting patchset mbox from LKML

The mbox downloads from the website have full email junk and are not in order.

1. Find cover email on https://lore.kernel.org/lkml/
2. Get message id of the email.
3. Run `b4 am <message_id>`

## Fixing patchset

If patchset fails to apply normally, can use `git am` to apply it on top of the
target tag in a git checkout. On failure, can run
`patch -p1 --no-backup-if-mismatch < .git/rebase-apply/00<XX>` to apply the
failed patch manually and fix it up.

To re-export:
`TERM=dumb git format-patch --stdout <base>..HEAD > patchset.mbx`.

## Generating linux-hardened mbox file

Checkout linux repo with linux-hardened and stable upstreams.

```
TAG=v6.18.31
PATCHV=1
HARDV=$TAG-hardened$PATCHV
TERM=dumb git format-patch --stdout $TAG..$HARDV^ > linux_hardened_$HARDV.mbx
```

We're skipping last commit as that just sets EXTRAVERSION.
