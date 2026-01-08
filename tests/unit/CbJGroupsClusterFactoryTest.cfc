component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "CbJGroupsClusterFactory", function() {
			it( "should be instantiable", function() {
				expect( function() {
					new cbjgroups.models.CbJGroupsClusterFactory();
				} ).notToThrow();
			} );

			it( "should have a getCluster method", function() {
				var factory = new cbjgroups.models.CbJGroupsClusterFactory();

				expect( factory ).toHaveKey( "getCluster" );
			} );

			it( "should have a shutdown method", function() {
				var factory = new cbjgroups.models.CbJGroupsClusterFactory();

				expect( factory ).toHaveKey( "shutdown" );
			} );
		} );
	}
}

