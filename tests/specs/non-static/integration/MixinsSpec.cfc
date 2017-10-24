component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    function run() {
        describe( "mixing in new methods to cfcollection", function() {
            it( "mixes in methods defined in the ColdBox configuration file", function() {
                // these methods are mixed in from the config/ColdBox.cfc file
                var nums = getInstance(
                    name = "Collection@CFCollection",
                    initArguments = { collection = [ 1, 2, 3, 4, 5 ] }
                );

                expect( nums.triple().get() ).toBe( [ 3, 6, 9, 12, 15 ] );
            } );

            it( "works with the collect function as well", function() {
                // these methods are mixed in from the config/ColdBox.cfc file
                var collect = getInstance( "collect@CFCollection" );
                var nums = collect( [ 1, 2, 3, 4, 5 ] );
                expect( nums.triple().get() ).toBe( [ 3, 6, 9, 12, 15 ] );
            } );
        } );
    }

}
