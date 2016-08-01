component {

    this.name = "Collection";
    this.author = "Eric Peterson";
    this.description = "An array wrapper for functional programming";
    this.version = "1.0.0";
    this.autoMapModels = false;

    function configure() {
        binder.map( "Collection" ).to( "#moduleMapping#.models.Collection" );

        if ( structKeyExists( server, "lucee" ) && server.lucee.version >= 5 ) {
            binder.map( "Collection" ).to( "#moduleMapping#.models.MacroableCollection" );
        }
    }

}