component {
	this.name = "cbjgroups Test Suite";

	this.mappings[ '/tests'   ] = ExpandPath( "/" );
	this.mappings[ '/testbox' ] = ExpandPath( "/testbox" );
	this.mappings[ '/cbjgroups' ] = ExpandPath( "../" );

	setting requesttimeout=60000;
}

