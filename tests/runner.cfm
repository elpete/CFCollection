<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.directory"           default="tests.specs.non-static" />
<cfif ( NOT structKeyExists( server, "lucee" ) || server.lucee.version LT 5 ) AND url.directory EQ "tests.specs">
    <cfset url.directory = "tests.specs.non-static" />
</cfif>
<cfparam name="url.reporter"            default="simple">
<cfparam name="url.recurse"             default="true" type="boolean">
<cfparam name="url.bundles"             default="">
<cfparam name="url.labels"              default="">
<cfparam name="url.reportpath"          default="#expandPath( "/tests/results" )#">
<cfparam name="url.propertiesFilename"  default="TEST.properties">
<cfparam name="url.propertiesSummary"   default="false" type="boolean">

<!--- Include the TestBox HTML Runner --->
<cfinclude template="/testbox/system/runners/HTMLRunner.cfm" >
