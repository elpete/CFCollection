component {

    public function getUser() {
        if ( structKeyExists( request, "user" ) ) {
            return request.user;
        }
        var newUser = wirebox.getInstance( "User" );
        if ( structKeyExists( session, "userId" ) ) {
            newUser.setId( session.userId );
        }
        return newUser;
    }

    public boolean function isLoggedIn() {
        return structKeyExists( session, "userId" ) && session.userId != "";
    }

    public boolean function login( User user ) {
        session.userId = arguments.user.getId();
        request.user = arguments.user;
        return true;
    }

    public void function logout() {
        structDelete( session, "userId" );
        structDelete( request, "user" );
    }

}
