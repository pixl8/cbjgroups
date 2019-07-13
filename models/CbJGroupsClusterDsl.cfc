/**
 * Singleton service for generating / retrieving instances of
 * the CbJGroupsCluster object. Ensures a single cluster
 * instance per unique cluster name
 *
 * @singleton
 */
component implements="coldbox.system.ioc.dsl.IDSLBuilder" {

	public any function init( required any injector ) {
		_setInjector( arguments.injector );

		return this;
	}

	public any function process( required any definition, any targetObject ) {
		var dsl       = ListRest( definition.dsl, ":" );
		var namespace = ListFirst( dsl, ":" );

		if ( namespace == "cluster" ) {
			var clusterName = ListRest( dsl, ":" );

			if ( Len( Trim( clusterName ) ) ) {
				return _getInjector().getInstance( "CbJGroupsClusterFactory@cbjgroups" ).getCluster( Trim( clusterName ) );
			}
		}
	}


// GETTERS AND SETTERS
	private any function _getInjector() {
		return _injector;
	}
	private void function _setInjector( required any injector ) {
		_injector = arguments.injector;
	}

}
