component accessors="true" {

    property name="id";
    property name="email";
    property name="username";
    property name="permissions";

    function init() {
        setPermissions( [] );
        return this;
    }

    public boolean function hasPermission( required string permission ) {
        return arrayContains( getPermissions(), permission );
    }

}
