public with sharing class RouteDataAccessor {
    public static List<Route_Street__c> getRouteStreets(Decimal streetNumber, String streetName, String postalCode) {
        System.debug(streetName);
        return [
            SELECT Id, Route__c
            FROM Route_Street__c 
            WHERE House_Low__c <= :streetNumber AND House_High__c >= :streetNumber
            AND From__c <= TODAY AND To__c >= TODAY
            AND Street_Name__c = :streetName
            AND ZIP__c = :postalCode
        ];
    }
}