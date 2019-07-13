package org.pixl8.cbjgroups;

import java.io.File;

import org.jgroups.*;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;

import lucee.loader.engine.*;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Struct;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import java.util.HashMap;

public class CbJGroupsMessageReceiver extends ReceiverAdapter {
	private CFMLEngine lucee;
	private Component  listenerCfc;
	private Component  logger;
	private File       contextRoot;

// CONSTRUCTOR
	public CbJGroupsMessageReceiver( Component listenerCfc, Component loggerCfc, String contextRoot ) throws PageException {
		this.lucee       = CFMLEngineFactory.getInstance();
		this.listenerCfc = listenerCfc;
		this.logger      = loggerCfc;
		this.contextRoot = new File( contextRoot );
	}

// JGroups Receiver interface overrides
	public void viewAccepted( View new_view ) {
		Struct args = _createStruct();
		args.put( "view", new_view );

		info( "viewAccepted: " + new_view );
		_callListenerCfc( "viewAccepted", args );
	}

	public void receive( Message msg ) {
		Struct args = _createStruct();
		args.put( "msg", msg );

		debug( "receive: " + msg.getObject() );
		_callListenerCfc( "receive", args );
	}

// LOGGING
	public void debug( String message ) {
		try {
			logger.call( _getPageContext(), "debug", new Object[]{ message } );
		} catch( PageException e ) {
		} catch( ServletException e ) {}
	}

	public void info( String message ) {
		try {
			logger.call( _getPageContext(), "info", new Object[]{ message } );
		} catch( PageException e ) {
		} catch( ServletException e ) {}
	}

	public void warn( String message ) {
		try {
			logger.call( _getPageContext(), "warn", new Object[]{ message } );
		} catch( PageException e ) {
		} catch( ServletException e ) {}
	}

	public void error( String message ) {
		try {
			logger.call( _getPageContext(), "error", new Object[]{ message } );
		} catch( PageException e ) {
		} catch( ServletException e ) {}
	}

// PRIVATE HELPERS
	private static Struct _createStruct() {
		return CFMLEngineFactory.getInstance().getCreationUtil().createStruct();
	}

	private void _callListenerCfc( String method, Struct args ) {
		try {
			listenerCfc.callWithNamedValues( _getPageContext(), method, args );
		} catch( PageException e ) {
			error( e.getMessage() );
		} catch( ServletException e ) {}
	}

	private PageContext _getPageContext() throws ServletException {
		PageContext pc = lucee.getThreadPageContext();

		if ( pc != null ) {
			return pc;
		}

		javax.servlet.http.Cookie[] cookies = new Cookie[]{};

		pc = lucee.createPageContext(
			  contextRoot
			, "localhost"    // host
			, "/"            // script name
			, ""             // query string
			, cookies		 // cookies
			, null           // headers
			, new HashMap()  // parameters
			, new HashMap()  // attributes
			, System.out     // response stream where the output is written to
			, 50000          // timeout for the simulated request in milli seconds
			, true           // register the pc to the thread
		);

		return pc;
	}
}
