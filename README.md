# cbjgroups: JGroups Integration for Coldbox

[![On Forgebox](https://forgebox.io/api/v1/entry/cbjgroups/badges/version)](https://forgebox.io/view/cbjgroups)

[![Build Status](https://travis-ci.org/pixl8/cbehcache.svg?branch=stable)](https://travis-ci.org/pixl8/cbehcache)

This extension provides a cluster communication system for ColdBox applications using [jGroups](http://www.jgroups.org/), a mature and maintained clustering API for java applications.

## Usage

### Obtaining a cluster object

Get a reference to a cluster object using the wirebox injection DSL: `cbjgroups:cluster:nameofcluster`. For instance:

```cfc
component {
	property name="myAppCluster" inject="cbjgroups:cluster:myAppCluster";
}
```

That's it! Your application will attempt to join an existing cluster named `myAppCluster` or, if not found, will start a new cluster with the name `myAppCluster` and join it. Any other nodes in the network that get an instance of the cluster object will automatically join it.

This minimal approach will assume all default settings. See cluster configuration below for details on more specific clustering options.

### Sending messages to the cluster

Once you have a cluster object, you can communicate with the other nodes in the cluster by calling the `runEvent()` method of your cluster object. This will run the specified coldbox event on all of the nodes in the cluster:


```cfc
component {
	property name="myAppCluster" inject="cbjgroups:cluster:myAppCluster";

	// ...

	myAppCluster.runEvent(
		  event          = "clusterListener.someEvent"
		, eventArguments = { test=true }
		, private        = true // default
		, prePostExempt  = true // default
	);
}
```

**Note:** when a coldbox event is run through the cluster in this way, an additional argument, `isCbJGroupsCall=true`, is sent so that you can prevent circular message loops in certain scenarios. For example, the corresponding handler for the call above could look like:

```cfc
component {

	property name="someService" inject="someService";

	private void function someEvent( event, rc, prc, test=false, isCbJGroupsCall=false ) {
		someService.doSomething( 
			  test               = arguments.test
			, propagageToCluster = !arguments.isCbJGroupsCall
		);
	}

}
```

### Getting stats

Call `myCluster.getStats()` to obtain a structure with reportable information about the cluster, including:

* `connection`: either `CONNECTED`, `CONNECTING`, `DISCONNECTED`, `CLOSED`
* `members`: an array of hostnames connected to the cluster
* `self`: hostname of this node, as appears in the `members` array
* `received_bytes`: number of bytes received from other nodes in the cluster
* `received_msgs`: number of messages received from other nodes in the cluster
* `sent_bytes`: number of bytes sent to other nodes in the cluster
* `sent_msgs`: number of messages sent to other nodes in the cluster

### Configuring individual clusters

You can register custom cluster settings in your application's Coldbox config file. The syntax is as follows:

```cfc
moduleSettings.cbjgroups.caches.myAppCluster = {
	  name                 = "my-app-cluster" // could be different from ID
	, jgroupsConfigXmlPath = ExpandPath( "/config/myClusterJgroupsConfig.xml" )
	, discardOwnMessages   = false // default is true
};
```

You can now inject `cbjgroups:cluster:myAppCluster` and the cluster will use the settings defined above.

#### Cluster name

This can be different from the cluster ID (i.e. `myAppCluster` vs `my-app-cluster`). This could be useful should you be creating a generic module with a default cluster ID that individual applications can configure to include their own application name for uniqueness.

#### jGroupsConfigXmlPath

Currently, the configuration is a *pure* jGroups implementation and the _default_ is to autodiscover peers to join the network using UDP. Leave the setting _empty_ to use this default.

Configuration is made through the specification of an XML file that 
contains the protocols to use, etc. The details of the content of this
file is beyond the scope of this document, however, the jGroups project is 
well documented: [http://www.jgroups.org](http://www.jgroups.org).

#### discardOwnMessages

If set to `true`, when `myCluster.runEvent()` is called, the system will not send the message to the node initiating the call. If `false`, it will. The default is `true`.

## Get involved

Contribution is very welcome. You can get involved by:

* Raising issues in [Github](https://github.com/pixl8/cbjgroups), both ideas and bugs welcome
* Creating pull requests in [Github](https://github.com/pixl8/cbjgroups)

Or search out the authors for anything else. You can generally find us on Preside slack: [https://presidecms-slack.herokuapp.com/](https://presidecms-slack.herokuapp.com/).
