component {

	this.title 				 = "cbjgroups";
	this.author 			 = "Pixl8 Group";
	this.description 		 = "Brings the clustering power of JGroups to Coldbox applications";
	this.entryPoint			 = "cbjgroups";
	this.cfmapping			 = "cbjgroups";
	this.modelNamespace		 = "cbjgroups";
	this.autoMapModels		 = true;
	this.parseParentSettings = true;

	function configure(){
		settings.clusters = {};

		controller.getWireBox().registerDSL(
			  namespace = "cbjgroups"
			, path      = "#moduleMapping#.models.CbJGroupsClusterDsl"
		);

		interceptorSettings = interceptorSettings ?: {};
		interceptorSettings.customInterceptionPoints = interceptorSettings.customInterceptionPoints ?: [];

		ArrayAppend( interceptorSettings.customInterceptionPoints, "onJgroupsClusterMemberChange" );
	}

	function applicationEnd(){
		try {
			wirebox.getInstance( "CbJGroupsClusterFactory@#this.modelNamespace#" ).shutdown();
		} catch( any e ) {
			SystemOutput( "Error shutting down JGroups clusters: #( e.message ?: '' )#. Detail: #( e.detail ?: '' )#" );
		}
	}

	function onApplicationEnd(){
		applicationEnd();
	}
}
