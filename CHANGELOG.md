# Changelog

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
