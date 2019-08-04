@isTest
public with sharing class TestQuickSearchController {
    
     static testMethod void getMetaDataOptions_Positive(){
        List<QuickSearchController.SelectOption> optionList = QuickSearchController.getMetaDataOptions();
        System.assertEquals(false, optionList.isEmpty());
    }
    
     static testMethod void getSelectedMetaDataItems_Negative1(){
         try {
             QuickSearchController.getSelectedMetaDataItems(null);
         } catch(Exception e) {
             System.assertEquals('Invalid Metadata Name', e.getMessage());
         }
    }

    static testMethod void getSelectedMetaDataItems_Negative2(){
        List<QuickSearchController.SelectOption> optionList = QuickSearchController.getSelectedMetaDataItems('InvalidOption');
        System.assertEquals(true, optionList.isEmpty());
    }

    static testMethod void getSelectedMetaDataItems_Positive(){
        Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
        List<QuickSearchController.SelectOption> optionList = QuickSearchController.getSelectedMetaDataItems('Apex Class');
        System.assertEquals(false, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Layout');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Apex Pages');
        System.assertEquals(false, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Static Resources');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Visualforce Components');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Objects');
        System.assertEquals(false, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Email Templates');
        System.assertEquals(false, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Workflow Rules');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Validation Rules');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Process Builder');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Flows');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Triggers');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Aura Components');
        System.assertEquals(false, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Lightning Pages');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Buttons & Quick Actions');
        System.assertEquals(false, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('Custom Setting');
        System.assertEquals(true, optionList.isEmpty());

        optionList = QuickSearchController.getSelectedMetaDataItems('MetaDataObjects');
        System.assertEquals(true, optionList.isEmpty());

    }
    public class YourHttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"entityTypeName":"Test", "size":2, "records" : []}');
            res.setStatusCode(200);
            return res;
        }
    }
}