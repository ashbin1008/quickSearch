public with sharing class QuickSearchController {
    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getMetaDataOptions() {

        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('Apex Class', 'Apex Class'));
        optionList.add(new SelectOption('Layout', 'Layout'));
        optionList.add(new SelectOption('Apex Pages', 'Apex Pages'));
        optionList.add(new SelectOption('Static Resources', 'Static Resources'));
        optionList.add(new SelectOption('Visualforce Components', 'Visualforce Components'));
        optionList.add(new SelectOption('Objects', 'Objects'));
        optionList.add(new SelectOption('Email Templates', 'Email Templates'));
        optionList.add(new SelectOption('Worlkflow Rules', 'Worlkflow Rules'));
        optionList.add(new SelectOption('Validation Rules', 'Validation Rules'));
        optionList.add(new SelectOption('Flows', 'Flows'));
        optionList.add(new SelectOption('Process Builder', 'Process Builder'));
        optionList.add(new SelectOption('Triggers', 'Triggers'));
        optionList.add(new SelectOption('Aura Components', 'Aura Components'));
        optionList.add(new SelectOption('Lightning Pages', 'Lightning Pages'));
        optionList.add(new SelectOption('Buttons & Quick Actions', 'Buttons & Quick Actions'));

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
            when 'Apex Class' {
                for(ApexClass records : [SELECT ID, Name FROM ApexClass Order By Name]){  
                    optionList.add(new SelectOption(records.Name , baseURL + 'ApexClasses/page?address=/' + records.Id));
                }
            }
            when 'Layout' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name, EntityDefinition.DeveloperName FROM Layout ORDER BY Name');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, baseURL + 'ObjectManager/' + (metRes.entityDefinition != null ? metRes.entityDefinition.DeveloperName : '') + '/PageLayouts/' + metRes.Id +'/view'));
                }
            }
            when 'Apex Pages' {
                for(ApexPage records : [SELECT ID, Name FROM ApexPage ORDER BY Name]){    
                    optionList.add(new SelectOption(records.Name, baseURL + 'ApexPages/page?address=/' + records.Id));
                }
            }
            
            when 'Static Resources' {
                for(StaticResource records : [SELECT ID, Name FROM StaticResource ORDER BY Name]){    
                    optionList.add(new SelectOption(records.Name, baseURL + 'StaticResources/page?address=/' + records.Id));
                }
            }
            when 'Visualforce Components' {
                for(ApexComponent records : [SELECT ID, Name FROM ApexComponent ORDER BY Name]){    
                    optionList.add(new SelectOption(records.Name, baseURL + 'ApexComponents/page?address=/' + records.Id));
                }
            }
            when 'Objects' {
                for(String records : Schema.getGlobalDescribe().keySet()){    
                    optionList.add(new SelectOption(records, baseURL + 'ObjectManager/' + records + '/Details/view'));
                }
            }
            when 'Email Templates' {
                for(EmailTemplate records : [SELECT ID, Name FROM EmailTemplate ORDER BY Name]){    
                    optionList.add(new SelectOption(records.Name, baseURL + 'CommunicationTemplatesEmail/page?address=/' + records.Id));
                }
            }
            when 'Worlkflow Rules' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name FROM WorkflowRule ORDER BY Name');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, baseURL + 'WorkflowRules/page?nodeId=WorkflowRules&address=/' + metRes.Id));
                }
            }
            when 'Validation Rules' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, ValidationName,EntityDefinition.DeveloperName FROM ValidationRule ORDER BY ValidationName');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.ValidationName, baseURL + 'ObjectManager/'+ metRes.entityDefinition.DeveloperName
                                                     + '/ValidationRules/' + metRes.Id + '/view'));
                }
            }
            when 'Process Builder' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DefinitionID, MasterLabel, VersionNumber FROM FLOW where ProcessType = \'Workflow\' or ProcessType = \'InvocableProcess\' ORDER BY MasterLabel');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.MasterLabel+' '+metRes.VersionNumber, baseURL+'ProcessAutomation/home'));
                }
            }
            when 'Flows' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DefinitionID, MasterLabel, VersionNumber FROM FLOW where ProcessType = \'Flow\' or ProcessType = \'AutoLaunchedFlow\' ORDER BY MasterLabel');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.MasterLabel+' '+metRes.VersionNumber, baseURL + 'InteractionProcesses/page?address=/' + metRes.definitionID));
                }
            }
            when 'Triggers' {
                for(ApexTrigger records : [SELECT ID, Name FROM ApexTrigger Order By Name]){    
                    optionList.add(new SelectOption(records.Name, baseURL + 'ApexClasses/page?address=/' + records.Id));
                }
            }
            when 'Aura Components' {
                for(AuraDefinitionBundle records : [SELECT ID, DeveloperName FROM AuraDefinitionBundle Order By DeveloperName]){    
                    optionList.add(new SelectOption(records.DeveloperName, baseURL + 'LightningComponentBundles/page?address=/' + records.Id));
                }
            }
            when 'Lightning Pages' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DeveloperName FROM FlexiPage ORDER BY DeveloperName');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.DeveloperName, baseURL + 'FlexiPageList/page?address=/' + metRes.Id));
                }
            }
            when 'Buttons & Quick Actions' {
                for(WebLink records : [SELECT ID, Name,PageOrSobjectType FROM WebLink Order By Name]){   
                    optionList.add(new SelectOption(records.Name, baseURL + 'ObjectManager/' + records.PageOrSobjectType + 
                                                                        '/ButtonsLinksActions/'+ records.Id+'/view'));
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
        @AuraEnabled public String definitionID;
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