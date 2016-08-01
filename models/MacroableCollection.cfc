component extends="Collection" {
    static = {
        macros = {}
    };

    public static function make( any collection ) {
        return new Collection( argumentCollection = arguments );
    }

    public static function macro( required string identifier, required func ) {
        static.macros[ identifier ] = func;
    }

    function onMissingMethod( string missingMethodName, struct missingMethodArguments ) {
        if ( ! structKeyExists( static, "macros" ) ) {
            static.macros = {};
        }

        if ( static.macros.keyExists( missingMethodName ) ) {
            var func = static.macros[ missingMethodName ];
            // Set the context of "this"
            missingMethodArguments.this = this;
            return func( argumentCollection = missingMethodArguments );
        }

        throw( "No method [#missingMethodName#] on `Collection`." );
    }
}