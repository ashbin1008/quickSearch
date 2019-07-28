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
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/setup/';
        switch on selectedMetaDataOption {
            when 'apexclass' {
                for(Sobject records : Database.query('SELECT ID, Name FROM ApexClass Order By Name')){    
                    optionList.add(new SelectOption(records.get('Name'), baseURL + 'ApexClasses/page?address=%2F' + records.get('Id')));
                }
            }
            when 'layout' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name, EntityDefinition.DeveloperName FROM Layout ORDER BY Name');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, baseURL + 'ObjectManager/' + metRes.entityDefinition.DeveloperName + '/PageLayouts/' + metRes.Id +'/view'));
                }
            }
            when 'apexpages' {
                for(Sobject records : Database.query('SELECT ID, Name FROM ApexPage ORDER BY Name')){    
                    optionList.add(new SelectOption(records.get('Name'), baseURL + 'ApexPages/page?address=%2F' + records.get('Id')));
                }
            }
            when 'staticresources' {
                for(Sobject records : Database.query('SELECT ID, Name FROM StaticResource ORDER BY Name')){    
                    optionList.add(new SelectOption(records.get('Name'), baseURL + 'StaticResources/page?address=%2F' + records.get('Id')));
                }
            }
            when 'visualforcecomponents' {
                for(Sobject records : Database.query('SELECT ID, Name FROM ApexComponent ORDER BY Name')){    
                    optionList.add(new SelectOption(records.get('Name'), baseURL + 'ApexComponents/page?address=%2F' + records.get('Id')));
                }
            }
            when 'Object' {
                for(String records : Schema.getGlobalDescribe().keySet()){    
                    optionList.add(new SelectOption(records, baseURL + 'ObjectManager/' + records + '/Details/view'));
                }
            }
            when 'emailtemplates' {
                for(Sobject records : Database.query('SELECT ID, Name FROM EmailTemplate ORDER BY Name')){    
                    optionList.add(new SelectOption(records.get('Name'), baseURL + 'CommunicationTemplatesEmail/page?address=%2F' + records.get('Id')));
                }
            }
            when 'worlkflowrules' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name FROM WorkflowRule ORDER BY Name');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, baseURL + 'WorkflowRules/page?address=%2F' + metRes.Id + '&nodeId=WorkflowRules'));
                }
            }
            when 'validationrules' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, ValidationName,EntityDefinition.DeveloperName FROM ValidationRule ORDER BY ValidationName');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.ValidationName, baseURL + 'ObjectManager/'+ metRes.entityDefinition.DeveloperName
                                                     + '/ValidationRules/' + metRes.Id + '/view'));
                }
            }
            when 'flows' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DefinitionID, MasterLabel, VersionNumber FROM FLOW ORDER BY MasterLabel');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.MasterLabel+' '+metRes.VersionNumber, URL.getSalesforceBaseUrl().toExternalForm() + 
                                                                                                'builder_platform_interaction/flowBuilder.app?flowDefId='
                                                                                                + metRes.definationID + '&flowId=' + metRes.Id));
                }
            }
        }
        return optionList;
    }
    private static String fetchUserSessionId(){
        if(Test.isRunningTest()) {
            return UserInfo.getSessionId();
        }
        PageReference reportPage = Page.SessionIdForCallout;
        String vfContent = reportPage.getContent().toString();
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
        Integer endP = vfContent.indexOf('End_Of_Session_Id');
        String sessionId = vfContent.substring(startP, endP);
        
        return sessionId;
    }
    private static MetadataResponseWrapper retrieveFromToolingApi(String query){
        String inputQuery = query.replace(' ','+');
        String currentRequestURL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v46.0/tooling/query/?q=';
        currentRequestURL += inputQuery;
        HTTP http = new Http();
        HttpRequest httpReq =  new HttpRequest();
        httpReq.setHeader('Authorization', 'Bearer ' + fetchUserSessionId());
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setEndPoint(currentRequestURL);
        httpReq.setMethod('GET');
        HttpResponse response = http.send(httpReq);
        return new MetadataResponseWrapper().parse(response.getBody());
    }
    public class MetadataResponseWrapper{
        @AuraEnabled public Integer size;
        @AuraEnabled public String entityTypeName;
        @AuraEnabled public MetaDataRecords[] records;
        public MetadataResponseWrapper parse(String json){
            return (MetadataResponseWrapper) System.JSON.deserialize(json, MetadataResponseWrapper.class);
        }
    }
    public class MetaDataRecords {
        @AuraEnabled public String id;
        @AuraEnabled public String definationID;
        @AuraEnabled public String name;
        @AuraEnabled public String developerName;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public String validationName;
        @AuraEnabled public Integer versionNumber;
        @AuraEnabled public cls_EntityDefinition entityDefinition;
    }
    public class cls_EntityDefinition {
        @AuraEnabled public String DeveloperName;
        @AuraEnabled public String Name;
    }
    
    public class SelectOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        SelectOption(Object label, Object name) {
            this.label = String.valueOf(label);
            this.value = String.valueOf(name);
        }
        SelectOption(String label, String name) {
            this.label = label;
            this.value = name;
        }
    }
}