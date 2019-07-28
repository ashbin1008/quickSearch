public with sharing class QuickSearchController {
    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getMetaDataOptions() {
        // List<Contact> contactList = [SELECT Id, Name  FROM Contact limit 50];

        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('Apex Class', 'apexclass'));
        optionList.add(new SelectOption('Layout', 'layout'));
        optionList.add(new SelectOption('Apex Pages', 'apexpages'));
        optionList.add(new SelectOption('Static Resources', 'staticresources'));
        optionList.add(new SelectOption('Visualforce Components', 'visualforcecomponents'));
        optionList.add(new SelectOption('Objects', 'objects'));
        optionList.add(new SelectOption('Email Templates', 'emailtemplates'));
        optionList.add(new SelectOption('Worlkflow Rules', 'worlkflowrules'));
        optionList.add(new SelectOption('Validation Rules', 'validationrules'));
        optionList.add(new SelectOption('Flows', 'flows'));
        optionList.add(new SelectOption('Process Builders', 'processbuilders'));
        optionList.add(new SelectOption('Approval Processes', 'approvalprocesses'));
        optionList.add(new SelectOption('Triggers', 'triggers'));
        optionList.add(new SelectOption('Aura Components', 'auracomponents'));
        optionList.add(new SelectOption('Lightning Pages', 'lightningpages'));
        optionList.add(new SelectOption('Buttons & Quick Actions', 'buttonsquickactions'));
        // optionList.add(new SelectOption('Lightning Web Components', 'lightningwebcomponents'));

        return optionList;
    }

    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getSelectedMetaDataItems(String selectedMetaDataOption) {
        if(String.isBlank(selectedMetaDataOption)){
            throw new AuraHandledException('Invalid Metadata Name');
        }
        List<SelectOption> optionList = new List<SelectOption>();
        switch on selectedMetaDataOption {
            when 'apexclass' {
                for(Sobject records : Database.query('SELECT ID, Name FROM ApexClass order by name')){    
                    optionList.add(new SelectOption(records.get('Name'), records.get('Id')));
                }
            }
            when 'layout' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name, EntityDefinition.DeveloperName FROM Layout');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, metRes.Id));
                }
            }
        }
        return optionList;
    }

    private static MetadataResponseWrapper retrieveFromToolingApi(String query){
        String inputQuery = query;
        String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm()+'/services/data/v46.0/tooling/query/?q=';
        currentRequestURL += inputQuery;
        HTTP http = new Http();
        HttpRequest httpReq =  new HttpRequest();
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setEndPoint(currentRequestURL);
        httpReq.setMethod('GET');
        HttpResponse response = http.send(httpReq);
        return new MetadataResponseWrapper().parse(response.getBody());
    }
    public class MetadataResponseWrapper{
        @AuraEnabled public Integer size;	//136
        @AuraEnabled public String entityTypeName;	//Layout
        @AuraEnabled public MetaDataRecords[] records;
        public MetadataResponseWrapper parse(String json){
            return (MetadataResponseWrapper) System.JSON.deserialize(json, MetadataResponseWrapper.class);
        }
    }
    public class MetaDataRecords {
        @AuraEnabled public String Id;	//00h0w000000GfBoAAK
        @AuraEnabled public String Name;	//Case (Marketing) Layout
        @AuraEnabled public String DeveloperName;
        @AuraEnabled public cls_EntityDefinition EntityDefinition;
    }
    public class cls_EntityDefinition {
        @AuraEnabled public String DeveloperName;	//Case
        @AuraEnabled public String Name;	//Case
    }
    
    public class SelectOption {
        @AuraEnabled public String label;
        @AuraEnabled public String name;

        SelectOption(Object label, Object name) {
            this.label = String.valueOf(label);
            this.name = String.valueOf(name);
        }

        SelectOption(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }
}