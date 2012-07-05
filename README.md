Apple Orchard: Scripts (bash & ruby) to support imaging of OSX machines

## Why?

We image OSX machines to use in conjunction with
[DeployStudio](http://www.deploystudio.com) in order to rapidly deploy developer
workstations with up-to-date images of the latest developer tools.

## How do I set it up?

If you're interested in setting it up yourself, please refer to our [Installation and Setup](https://github.com/pivotalexperimental/apple_orchard/wiki/Installation-and-Setup)

## What do I need?

You'll need a [Jenkins](http://jenkins-ci.org/) server and an OS X machine with two partitions, each big enough to hold a complete OS (30GB each partition); we are currently experimenting running the OS X machine under VMWare Fusion.

## Bugs
This process doesn't capture recovery partitions (i.e. a newly-imaged machine won't have a recovery partition).  This doesn't seem to be a DeployStudio bug; rather, it appears to be the way in which we update images on DeployStudio.

The large majority of failures are from the DeployStudio share not mounted on boot by the OS X machine's "Persistent" personality.

# To whom do we complain?
**apple_orchard** started as a side project of [Matthew
Kocher](https://github.com/mkocher) and [Brian
Cunnie](https://github.com/briancunnie) of Pivotal Labs in Summer 2011.
