@isTest
private class RouteDataAccessorTest {
    @isTest static void shouldGetRouteDetails() {
        TestDataFactory.createRoutes();
        RouteDataAccessor.getRouteStreets(200.00, 'Maple', '11111');
    }
}