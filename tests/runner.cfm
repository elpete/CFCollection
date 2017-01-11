<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfset directory = ( structKeyExists( server, "lucee" ) && server.lucee.version GTE 5 ) ? "tests.specs" : "tests.specs.non-static" />
<cfparam name="url.reporter"            default="simple">
<cfparam name="url.directory"           default="#directory#">
<cfparam name="url.recurse"             default="true" type="boolean">
<cfparam name="url.bundles"             default="">
<cfparam name="url.labels"              default="">
<cfparam name="url.reportpath"          default="#expandPath( "/tests/results" )#">
<cfparam name="url.propertiesFilename"  default="TEST.properties">
<cfparam name="url.propertiesSummary"   default="false" type="boolean">

<!--- Include the TestBox HTML Runner --->
<cfinclude template="/testbox/system/runners/HTMLRunner.cfm" >