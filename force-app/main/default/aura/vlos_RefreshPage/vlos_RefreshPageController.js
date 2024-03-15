({
    invoke : function(component, event, helper) {
        var navService = component.find('navService');
        var destinationRecordId = component.get('v.destinationRecordId');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The User was created successfully. You'll soon receive a welcome email.",
            "type":"success"
        });
        //toastEvent.fire();
        //$A.get('e.force:refreshView').fire();
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'view',
                recordId: destinationRecordId
            }
        }
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            window.location.replace(url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            window.location.replace(defaultUrl);
        }));
        
    }
})