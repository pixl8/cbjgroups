/**
 * Object to represent a cluster. Once instantiated,
 * this object provides an API to run ColdBox
 * events across your cluster and takes care of
 * receiving and processing requests from other
 * members of your cluster.
 *
 */
component {

// CONSTRUCTOR
	public any function init(
		  required string  clusterName
		, required string  jgroupsConfigXmlPath
		, required boolean discardOwnMessages
		, required any     logger
		, required any     coldbox
	) {
		_setLogger( arguments.logger );
		_setClusterName( arguments.clusterName );
		_setJGroupsConfigXmlPath( arguments.jgroupsConfigXmlPath );
		_setColdbox( arguments.coldbox );
		_setDiscardOwnMessages( arguments.discardOwnMessages );
		_setApplicationContext( getPageContext().getApplicationContext() );
		_setLockName( "cluster-#arguments.clusterName#-instance-lock-#getApplicationMetadata().name#-#getCurrentTemplatePath()#" );

		return this;
	}

// PUBLIC API METHODS
	/**
	 * Connect to the cluster
	 *
	 */
	public void function connect() {
		if ( !_isConnected() ) {
			lock type="exclusive" name=_getLockname() timeout=0 {
				if ( !_isConnected() ) {
					_getLogger().info( "Connecting to jGroups cluster: [#_getClusterName()#]..." );
					if ( !_isClusterInitialised() ) {
						_setupCluster();
					}

					_getClusterWrapper().connect( _getClusterName() );

					_getLogger().info( "Connected to jGroups cluster: [#_getClusterName()#]" );
				}
			}
		}
	}

	/**
	 * Implement shutdown() method to safely
	 * disconnect when shutting down/restarting Coldbox
	 *
	 */
	public void function shutdown() {
		try {
			_getLogger().info( "Disconnecting from jGroups cluster [#_getClusterName()#]..." );
			_getClusterWrapper().close();
			_getLogger().info( "Completed disconnecting from jGroups cluster [#_getClusterName()#]." );
		} catch( any e ) {
			_getLogger().error( e );
		}
	}

	/**
	 * Main method for running events
	 * across the cluster. Works much
	 * like coldbox runEvent except:
	 *
	 * * prePostExempt + private default to true
	 * * event is run on nodes in the cluster
	 */
	public void function runEvent(
		  required string  event
		,          struct  eventArguments={}
		,          boolean prePostExempt = true
		,          boolean private       = true
	) {
		_getClusterWrapper().sendMessage( SerializeJson( {
			  event          = arguments.event
			, eventArguments = arguments.eventArguments
			, prePostExempt  = arguments.prePostExempt
			, private        = arguments.private
		} ) );
	}

	/**
	 * Receives messages from other nodes in the cluster.
	 * Assumes it is a coldbox runevent message and
	 * attempts to run it (safely logs error otherwise)
	 */
	public void function receive( required any msg ) {
		_setupApplicationContext();

		try {
			var message = DeserializeJson( _binaryToString( msg.getBuffer() ), false );
			message.eventArguments.isCbJGroupsCall = true;

			_getColdbox().getRequestService().getContext().setValue( name="_isCbJGroupsCall", value=true, private=true );
			_getColdbox().runEvent(
				  event          = message.event
				, eventArguments = message.eventArguments
				, prePostExempt  = message.prePostExempt
				, private        = message.private
			);
		} catch( any e ) {
			try {
				_getLogger().error( e );
			} catch( any e ){}
		}
	}

	/**
	 * Get info on the cluster
	 *
	 */
	public any function getStats() {
		return _getClusterWrapper().getStats();
	}

	/**
	 * Returns whether or not the node running this logic
	 * is the "co-ordinator" in the cluster
	 *
	 */
	public boolean function isCoordinator() {
		return _getClusterWrapper().isCoordinator();
	}

	/**
	 * Called when a change in membership has occurred
	 *
	 */
	public void function viewAccepted( required any view  ) {
		_setupApplicationContext();
		_announceInterception( "onJgroupsClusterMemberChange", { view=arguments.view } );
	}

// PRIVATE HELPERS
	private void function _setupCluster() {
		_registerOsgiBundle();

		_setClusterWrapper( CreateObject( "java", "org.pixl8.cbjgroups.CbJGroupsClusterWrapper", "org.pixl8.cbjgroups" ).init(
			, _getJGroupsConfigXmlPath() // configFilePath
			, _getDiscardOwnMessages()   // discardOwnMessages
			, this                       // listenerCfc
			, _getLogger()               // loggerCfc
			, ExpandPath( "/" )          // contextRoot
		) );
	}

	private function _registerOsgiBundle() {
		if ( !StructKeyExists( application, "_cbjgroupsBundleRegistered" ) ) {
			var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
			var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
			var lib        = ExpandPath( GetDirectoryFromPath(GetCurrentTemplatePath()) & "../lib/cbjgroups-1.0.0.jar" );
			var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

			osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );

			application._cbjgroupsBundleRegistered = true;
		}
	}

	private any function _setupApplicationContext() {
		getPageContext().setApplicationContext( _getApplicationContext() );
	}

	private boolean function _isConnected() {
		return _isClusterInitialised() && _getClusterWrapper().isConnected();
	}

	private boolean function _isClusterInitialised() {
		var channel = _getClusterWrapper();

		return !IsNull( local.channel );
	}

	private void function _announceInterception() {
		return _getColdbox().getInterceptorService().processState( argumentCollection=arguments );
	}

	private any function _binaryToString( required any binaryValue ){
		return ToString( arguments.binaryValue );
	}

// GETTERS AND SETTERS
	private any function _getLogger() {
	    return _logger;
	}
	private void function _setLogger( required any logger ) {
	    _logger = arguments.logger;
	}

	private any function _getApplicationContext() {
		return _applicationContext;
	}
	private void function _setApplicationContext( required any applicationContext ) {
		_applicationContext = arguments.applicationContext;
	}

	private any function _getClusterWrapper() {
	    return _channel ?: NullValue();
	}
	private void function _setClusterWrapper( required any channel ) {
	    _channel = arguments.channel;
	}

	private string function _getClusterName() {
	    return _clusterName;
	}
	private void function _setClusterName( required string clusterName ) {
	    _clusterName = arguments.clusterName;
	}

	private string function _getJGroupsConfigXmlPath() {
	    return _configXmlPath;
	}
	private void function _setJGroupsConfigXmlPath( required string configXmlPath ) {
	    _configXmlPath = arguments.configXmlPath;
	}

	private string function _getLockName() {
	    return _lockName;
	}
	private void function _setLockName( required string lockName ) {
	    _lockName = arguments.lockName;
	}

	private any function _getColdbox() {
	    return _coldbox;
	}
	private void function _setColdbox( required any coldbox ) {
	    _coldbox = arguments.coldbox;
	}

	private boolean function _getDiscardOwnMessages() {
	    return _discardOwnMessages;
	}
	private void function _setDiscardOwnMessages( required boolean discardOwnMessages ) {
	    _discardOwnMessages = arguments.discardOwnMessages;
	}
}
