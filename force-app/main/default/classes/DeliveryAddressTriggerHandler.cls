public class DeliveryAddressTriggerHandler {
    private Map<Id, Delivery_Address__c> deliveryAddresses;
    private Map<Id, Delivery_Address__c> oldDeliveryAddresses;

    public DeliveryAddressTriggerHandler(Map<Id, Delivery_Address__c> deliveryAddresses, Map<Id, Delivery_Address__c> oldDeliveryAddresses) {
        this.deliveryAddresses = deliveryAddresses;
        this.oldDeliveryAddresses = oldDeliveryAddresses;
    }
    
    public void resetMelissaResponseBeforePersonatorExecutes() {
        if (!Test.isRunningTest() && !System.isFuture() && !System.isBatch() && deliveryAddresses.size() == 1) {
            Delivery_Address__c deliveryAddress = deliveryAddresses.values()[0];
            if ((oldDeliveryAddresses == null || addressFieldsChanged(deliveryAddress)) && !dsiIdHasChanged(deliveryAddress)) {
                deliveryAddress.Melissa_Response__c = null;
            }
        }
    }

	public void runMelissaDataPersonator() {
        if (!Test.isRunningTest() && !System.isFuture() && !System.isBatch() && deliveryAddresses.size() == 1) {
            Delivery_Address__c deliveryAddress = deliveryAddresses.values()[0];
            if ((oldDeliveryAddresses == null || addressFieldsChanged(deliveryAddress)) && (oldDeliveryAddresses == null || !dsiIdHasChanged(deliveryAddress))) {
                MDPERSONATOR.MD_PersonatorWSExt.doOnePersonator((String)deliveryAddress.Id);
            }
        }
    }

    public void updateAddressAfterPersonatorExecutes() {
        if (System.isFuture() && !System.isBatch() && deliveryAddresses.size() == 1) {
            for (Delivery_Address__c deliveryAddress : deliveryAddresses.values()) {
                if(!dsiIdHasChanged(deliveryAddress)){
                    MDPERSONATOR__MD_personatorResult__c personatorResult = getPersonatorResult(deliveryAddress.Id);
                    applyDeliveryCleanSuiteChanges(deliveryAddress, personatorResult);
                    setRouteFromDeliveryAddress(deliveryAddress);
                    if (deliveryAddress.Route_Number__c != null) {
                        deliveryAddress.Ready_for_DSI__c = true;
                    }
                }
            }
        }
    }

    private void setRouteFromDeliveryAddress(Delivery_Address__c deliveryAddress) {
        if (!String.isEmpty(deliveryAddress.Address_House__c)) {
            List<Route_Street__c> relatedRouteStreets = RouteDataAccessor.getRouteStreets(Decimal.valueOf(deliveryAddress.Address_House__c), deliveryAddress.Address_Street__c, deliveryAddress.Zip__c);
            deliveryAddress.Route_Number__c = (relatedRouteStreets.isEmpty()) ? null : relatedRouteStreets[0].Route__c;
        }
    }

    private Boolean addressFieldsChanged(Delivery_Address__c deliveryAddress) {
        Delivery_Address__c oldDeliveryAddress = oldDeliveryAddresses.get(deliveryAddress.Id);

        return (deliveryAddress.Address_House__c  != oldDeliveryAddress.Address_House__c) ||
            (deliveryAddress.Pre_Direction__c  != oldDeliveryAddress.Pre_Direction__c) ||
            (deliveryAddress.Address_Street__c  != oldDeliveryAddress.Address_Street__c) ||
            (deliveryAddress.Address_Suffix__c  != oldDeliveryAddress.Address_Suffix__c) ||
            (deliveryAddress.Post_Direction__c  != oldDeliveryAddress.Post_Direction__c) ||
            (deliveryAddress.Address_City__c != oldDeliveryAddress.Address_City__c) ||
            (deliveryAddress.Address_State__c != oldDeliveryAddress.Address_State__c) ||
            (deliveryAddress.Zip__c != oldDeliveryAddress.Zip__c);
    }

    private void applyDeliveryCleanSuiteChanges(Delivery_Address__c deliveryAddress, MDPERSONATOR__MD_personatorResult__c personator) {
        if (personator != null) {
            deliveryAddress.Address_House__c = personator.MDPERSONATOR__AddressHouseNumber__c;
            deliveryAddress.Pre_Direction__c = personator.MDPERSONATOR__AddressPreDirection__c;
            deliveryAddress.Post_Direction__c = personator.MDPERSONATOR__AddressPostDirection__c;
            deliveryAddress.Address_Street__c = personator.MDPERSONATOR__AddressStreetName__c;
            deliveryAddress.Address_Suffix__c = personator.MDPERSONATOR__AddressStreetSuffix__c;
            deliveryAddress.Address_City__c = personator.MDPERSONATOR__City__c;
            deliveryAddress.Address_State__c = personator.MDPERSONATOR__State__c;
            deliveryAddress.Zip__c = personator.MDPERSONATOR__PostalCode__c.substring(0, 5);
        }
    }

    private MDPERSONATOR__MD_personatorResult__c getPersonatorResult(Id recordId) {
        return [ SELECT Id, MDPERSONATOR__AddressHouseNumber__c, 
                MDPERSONATOR__AddressPreDirection__c, 
                MDPERSONATOR__AddressPostDirection__c, 
                MDPERSONATOR__AddressStreetName__c, 
                MDPERSONATOR__AddressStreetSuffix__c, 
                MDPERSONATOR__AddressLine1__c, 
                MDPERSONATOR__City__c, 
                MDPERSONATOR__State__c	, 
                MDPERSONATOR__PostalCode__c
            FROM MDPERSONATOR__MD_personatorResult__c 
            WHERE MDPERSONATOR__RecordID__c = :recordId
        ];
    }

    private Boolean dsiIdHasChanged(Delivery_Address__c deliveryAddress){
        Delivery_Address__c oldDeliveryAddress = oldDeliveryAddresses.get(deliveryAddress.Id);
        if (oldDeliveryAddress.DSI_Id__c != deliveryAddress.DSI_Id__c) {
            return true;
        }   
        return false;
    }
}