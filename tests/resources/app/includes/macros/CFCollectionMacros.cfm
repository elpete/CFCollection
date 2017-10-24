<cfscript>
function triple() {
    return this.map( function( item ) {
        return item * 3;
    } );
}
</cfscript>
