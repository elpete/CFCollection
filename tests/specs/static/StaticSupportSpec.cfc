component extends="testbox.system.BaseSpec" {

    function run() {
        describe( title = "static support", body = function() {
            describe( "static construction", function() {
                it( "can create a new collection via a static method", function() {
                    var collection = models.MacroableCollection::make();

                    expect( collection ).toBeInstanceOf( "models.Collection" );
                } );
            } );

            describe( "macro support", function() {
                it( "can statically add macros", function() {
                    models.MacroableCollection::macro( "mySum", function( field ) {
                        return this.reduce( function( acc, item ) {
                            return acc + item[ field ];
                        }, 0 );
                    } );

                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = 10;

                    var collection = new models.MacroableCollection( data );
                    var actual = collection.mySum( "value" );
                    expect( actual ).toBe( expected );
                } );
            } );
        }, skip = function() {
            return structKeyExists( server, "lucee" ) && server.lucee.version < 5;
        } );
    }

}