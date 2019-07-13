/**
 * Singleton service for generating / retrieving instances of
 * the CbJGroupsCluster object. Ensures a single cluster
 * instance per unique cluster name
 *
 * @singleton
 */
component {

	property name="coldbox"  inject="coldbox";
	property name="logger"   inject="logbox:logger";
	property name="settings" inject="coldbox:setting:cbjgroups@cbjgroups";

	variables._clusters = {};

	public any function init() {
		return this;
	}

	public any function getCluster( required string name ) {
		var clusterKey = "_cbJGroupsCluster#arguments.name#";

		lock type="exclusive" name=clusterKey timeout=5 {
			if ( !StructKeyExists( variables._clusters, clusterKey ) ) {
				var settings = _getClusterSettings( arguments.name );

				variables._clusters[ clusterKey ] = new CbJGroupsCluster(
					  clusterName          = settings.name
					, jgroupsConfigXmlPath = settings.jgroupsConfigXmlPath
					, discardOwnMessages   = settings.discardOwnMessages
					, logger               = variables.logger
					, coldbox              = variables.coldbox
				);

				variables._clusters[ clusterKey ].connect();
			}

			return variables._clusters[ clusterKey ];
		}
	}

	public any function shutdown() {
		for( var clusterName in variables._clusters ) {
			variables._clusters[ clusterName ].shutdown();
		}
	}


// PRIVATE HELPERS
	private struct function _getClusterSettings( required string clusterName  ) {
		return {
			  name                 = settings.clusters[ arguments.clusterName ].name                 ?: arguments.clusterName
			, jgroupsConfigXmlPath = settings.clusters[ arguments.clusterName ].jgroupsConfigXmlPath ?: ""
			, discardOwnMessages   = settings.clusters[ arguments.clusterName ].discardOwnMessages   ?: true
		};
	}
}
