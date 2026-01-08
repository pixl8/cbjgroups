package org.pixl8.cbjgroups;

import java.io.File;
import java.io.FileInputStream;
import java.util.Map;
import java.io.FileNotFoundException;

import org.jgroups.*;
import lucee.runtime.Component;
import lucee.runtime.exp.PageException;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.type.Struct;
import lucee.runtime.type.Array;


public class CbJGroupsClusterWrapper {

	private JChannel _channel;

// CONSTRUCTOR
	public CbJGroupsClusterWrapper( String configFilePath, Boolean discardOwnMessages,  Component listenerCfc, Component loggerCfc, String contextRoot ) throws PageException, FileNotFoundException, Exception {
		if ( configFilePath.length() > 0 ) {
			_channel = new JChannel( new FileInputStream( new File( configFilePath ) ) );
		} else {
			_channel = new JChannel();
		}

		_channel.setDiscardOwnMessages( discardOwnMessages );
		_channel.setReceiver( new CbJGroupsMessageReceiver( listenerCfc, loggerCfc, contextRoot ) );
	}

// PUBLIC API
	public Boolean connect( String clusterName ) throws Exception {
		if ( !isConnected() ) {
			_channel.connect( clusterName );
			return isConnected();
		}
		return true;
	}

	public void close() {
		_channel.disconnect();
		_channel.close();
	}

	public Boolean isConnected() {
		return _channel.isConnected();
	}

	public void sendMessage( String msg ) throws Exception {
		_channel.send( new Message( null, msg.getBytes() ) );
	}

	public Struct getStats() throws PageException {
		Struct              stats           = CFMLEngineFactory.getInstance().getCreationUtil().createStruct();
		Array               memberAddresses = CFMLEngineFactory.getInstance().getCreationUtil().createArray();
		Address[]           members         = _channel.getView().getMembersRaw();
		Map<String, Object> dumpStats       = (Map<String, Object>)_channel.dumpStats().get( "channel" );

		for (String key : dumpStats.keySet()) {
			stats.put( key, dumpStats.get( key ) );
		}
		for( int i=0; i<members.length; i++ ) {
			memberAddresses.append( members[i].toString() );
		}

		stats.put( "members", memberAddresses );
		stats.put( "self", _channel.getAddress().toString() );
		stats.put( "is_coordinator", members.length <= 1 || members[0].equals( _channel.getAddress() ) );

		if ( _channel.isConnected() ) {
			stats.put( "connection", "CONNECTED" );
		} else if ( _channel.isConnecting() ) {
			stats.put( "connection", "CONNECTING" );
		} else if ( _channel.isOpen() ) {
			stats.put( "connection", "DISCONNECTED" );
		} else {
			stats.put( "connection", "CLOSED" );
		}

		return stats;
	}

	public Boolean isCoordinator() {
		Address[] members = _channel.getView().getMembersRaw();

		return members.length <= 1 || members[0].equals( _channel.getAddress() );
	}
}
