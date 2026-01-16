component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "CbJGroupsCluster", function() {
			it( "should be instantiable with required parameters", function() {
				expect( function() {
					_getServiceUnderTest();
				} ).notToThrow();
			} );

			it( "should have a shutdown method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "shutdown" );
			} );

			it( "should have a connect method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "connect" );
			} );

			it( "should have a runEvent method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "runEvent" );
			} );

			it( "should have a receive method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "receive" );
			} );

			it( "should have a getStats method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "getStats" );
			} );

			it( "should have an isCoordinator method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "isCoordinator" );
			} );

			it( "should have a viewAccepted method", function() {
				var jgCluster = _getServiceUnderTest();

				expect( jgCluster ).toHaveKey( "viewAccepted" );
			} );
		} );

		describe( "Connect()", function(){
			it( "should connect to the cluster", function() {
				var configPath = ExpandPath( "/tests/fixtures/jgroups-localhost.xml" );
				var jgCluster   = _getServiceUnderTest( jgroupsConfigXmlPath=configPath );

				jgCluster.connect();

				expect( jgCluster.isConnected() ).toBeTrue();

				jgCluster.shutdown();
			} );
		} );
	}

	private function _getServiceUnderTest() {
		var mockLogger = CreateStub();
		var mockColdbox = CreateStub();

		mockLogger.$( "info" );
		mockLogger.$( "warn" );
		mockLogger.$( "error" );
		mockLogger.$( "debug" );

		return new cbjgroups.models.CbJGroupsCluster(
			  clusterName          = arguments.clusterName          ?: "test-cluster"
			, jgroupsConfigXmlPath = arguments.jgroupsConfigXmlPath ?: "/path/to/config.xml"
			, discardOwnMessages   = arguments.discardOwnMessages   ?: true
			, logger               = mockLogger
			, coldbox              = mockColdbox
		);
	}
}

