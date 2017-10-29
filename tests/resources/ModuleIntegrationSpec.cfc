component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();

        getController().getModuleService()
            .registerAndActivateModule(
                moduleName = "cfcollection",
                invocationPath = "testingModuleRoot",
                force = true
            );
    }

    /**
    * @beforeEach
    */
    function setupIntegrationTest() {
        setup();
    }

}
