component {

    this.name = "collection_tests_" & hash( getCurrentTemplatePath() );
    this.mappings["/tests"] = getDirectoryFromPath( getCurrentTemplatePath() );
    rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
    this.mappings[ "/root" ] = rootPath;

}