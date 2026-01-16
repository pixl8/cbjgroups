# CFML JGroups Cluster Receiver

Source code for building jars for creating a JGroups message receiver using a CFML component.

## Building the jars

Ensure you have maven installed and then run: 

* `mvn package` will build the jars which can then be found in the `./artifacts` directory.
* `mvn clean` will remove all temporary files and built dist files.