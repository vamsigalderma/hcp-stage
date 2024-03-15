/*******************************************************************************************
* @Name         NavigationLinkSetPickList 
* @Author       Vamsi Krishna
* @Description  This class is used to create the dynamic naviagtion menu in LWR Sites.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0            Vamsi Krishna      08/11/2023           Initial Creation                                                      
*******************************************************************************************/
global class NavigationLinkSetPickList extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            'Default Navigation',
            'Default Navigation'
        );
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        List<NavigationLinkSet> navigationLinkSetList = [
            SELECT MasterLabel, DeveloperName
            FROM NavigationLinkSet
        ];
        for (NavigationLinkSet navigationLinkSet : navigationLinkSetList) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                navigationLinkSet.MasterLabel,
                navigationLinkSet.DeveloperName
            );
            picklistValues.addRow(value);
        }
        return picklistValues;
    }
}