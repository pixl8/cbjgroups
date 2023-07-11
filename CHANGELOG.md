# Changelog

## 0.3.3

* [#14](https://github.com/pixl8/cbjgroups/issues/14) Fix issue with try/catch logic using Preside helper function that is unavailable to this non-Preside-specific service

## 0.3.2

* [#12](https://github.com/pixl8/cbjgroups/issues/12) Fix memory leak issue in core KUBE_PING java library by upgrading the upstream lib

## 0.3.1

* [#11](https://github.com/pixl8/cbjgroups/issues/11) Fix issue where app context is missing when running logic when cluster membership changes


## 0.3.0

* [#9](https://github.com/pixl8/cbjgroups/issues/9) Add method on cluster to determine whether or not this member is the coordinator
* [#10](https://github.com/pixl8/cbjgroups/issues/10) Raise coldbox interception event whenever membership of the cluster changes

## 0.2.4

* [#7](https://github.com/pixl8/cbjgroups/issues/7) Fix issue introduced in #6 where messages would not be received
* [#8](https://github.com/pixl8/cbjgroups/issues/8) Switch to Github actions building flow

## 0.2.3

* [#6](https://github.com/pixl8/cbjgroups/issues/6) Fix issue with message length limitations

## 0.2.2

* [#3](https://github.com/pixl8/cbjgroups/issues/3) Fix for missing var scope in message receive method
* [#4](https://github.com/pixl8/cbjgroups/issues/4) Fix for bad query deserialization when receiving messages

## 0.2.1

* Fix for mapping issues when reading the lib
* Fix for errors logged in the console when cluster is connected to

## 0.2.0

* Build in the Kubernetes ping autodiscovery to the library

## v0.1.6

* Change 'moduleconfig.cbjgroups.caches' to .. 'clusters'!

## v0.1.5

* Fix for bad module configuration injection into the factory

## v0.1.4

* README fix (build status badge pointing at wrong repo)

## v0.1.3

* Add status badges to README

## v0.1.2

Initial release with support for creating/joining a JGroups cluster, providing custom networking config, and sending/receiving messages in the cluster to execute Coldbox events.
