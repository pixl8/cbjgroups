/**
 * Object to represent a cluster. Once instantiated,
 * this object takes provides an API to run ColdBox
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
					if ( !_isJChannelInitialized() ) {
						_setupJChannel();
					}

					var channel = _getChannel();

					channel.setReceiver( _setupReceiver() );
					channel.connect( _getClusterName() );

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
			_getChannel().close();
			_getLogger().info( "Completed disconnecting from jGroups cluster [#_getClusterName()#]." );
		} catch( any e ) {
			$raiseError( e );
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
		_getChannel().send( _getMessage( SerializeJson( {
			  event          = arguments.event
			, eventArguments = arguments.eventArguments
			, prePostExempt  = arguments.prePostExempt
			, private        = arguments.private
		} ) ) );
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
		var stats   = {};
		var channel = _getChannel();
		var members = channel.getView().getMembers();

		stats.append( channel.dumpStats().channel );
		stats.members = [];
		stats.self = channel.getAddress().toString();

		for( var i=1; i<=ArrayLen( members ); i++ ) {
			stats.members.append( members[ i ].toString() );
		}
		stats.is_coordinator = ArrayLen( stats.members ) <= 1 || stats.members[ 1 ] == stats.self;

		if ( channel.isConnected() ) {
			stats.connection = "CONNECTED";
		} else if ( channel.isConnecting() ) {
			stats.connection = "CONNECTING";
		} else if ( channel.isOpen() ) {
			stats.connection = "DISCONNECTED";
		} else {
			stats.connection = "CLOSED";
		}

		return stats;
	}

	/**
	 * Returns whether or not the node running this logic
	 * is the "co-ordinator" in the cluster
	 *
	 */
	public boolean function isCoordinator() {
		var channel = _getChannel();
		var members = channel.getView().getMembers();
		var self = channel.getAddress().toString();

		return ArrayLen( members ) <= 1 || members[ 1 ].toString() == self;
	}

	/**
	 * Called when a change in membership has occurred
	 *
	 */
	public void function viewAccepted( required any view  ) {
		// TODO, something here at some point. Just implementing the method means we avoid errors
		// being logged.
	}

// PRIVATE HELPERS
	private void function _setupJChannel() {
		var configXmlPath = _getJGroupsConfigXmlPath();
		var channel = "";

		// user specified config
		if ( Len( Trim( configXmlPath ) ) ) {
			if ( !FileExists( configXmlPath ) ) {
				throw( type="cbjgroups.bad.config", message="The configured XML config file, [#configXmlPath#], could not be found." );
			}
			var configFile = CreateObject( "java", "java.io.File" ).init( configXmlPath );
			channel = CreateObject( "java", "org.jgroups.JChannel", _getLib() ).init( configFile );

		// default jgroups config
		} else {
			channel = CreateObject( "java", "org.jgroups.JChannel", _getLib() ).init();
		}

		channel.setDiscardOwnMessages( JavaCast( "Boolean", _getDiscardOwnMessages() ) );

		_setChannel( channel );
	}

	private any function _setupReceiver(){
		return CreateObject( "java", "org.pixl8.cbjgroups.CbJGroupsMessageReceiver", _getLib() ).init(
			  this              // ListenerCFC
			, _getLogger()      // LoggerCFC
			, ExpandPath( "/" ) // Context path
		);
	}

	private array function _getLib() {
		return DirectoryList( ExpandPath( GetDirectoryFromPath(GetCurrentTemplatePath()) & "../lib" ), false, "path" );
	}

	private any function _setupApplicationContext() {
		getPageContext().setApplicationContext( _getApplicationContext() );
	}

	private any function _getMessage( required string message ) {
		return CreateObject( "java", "org.jgroups.Message", _getLib() ).init( NullValue(), _stringToBinary( arguments.message ) );
	}

	private boolean function _isConnected() {
		return _isJChannelInitialized() && _getChannel().isConnected();
	}

	private boolean function _isJChannelInitialized() {
		var channel = _getChannel();

		return !IsNull( local.channel );
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

	private any function _getChannel() {
	    return _channel ?: NullValue();
	}
	private void function _setChannel( required any channel ) {
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

	private any function _stringToBinary( required string stringValue ){
		var base64Value = ToBase64( stringValue );
		var binaryValue = ToBinary( base64Value );

		return binaryValue ;
	}
	private any function _binaryToString( required any binaryValue ){
		return ToString( arguments.binaryValue );
	}
}
