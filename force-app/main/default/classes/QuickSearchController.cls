public with sharing class QuickSearchController {
    private static String labelToDisplay = '{0} ({1})';

    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getMetaDataOptions() {

        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('Apex Classes', 'Apex Class'));
        optionList.add(new SelectOption('Layouts', 'Layout'));
        optionList.add(new SelectOption('Apex Pages', 'Apex Pages'));
        optionList.add(new SelectOption('Static Resources', 'Static Resources'));
        optionList.add(new SelectOption('Visualforce Components', 'Visualforce Components'));
        optionList.add(new SelectOption('Objects', 'Objects'));
        optionList.add(new SelectOption('Email Templates', 'Email Templates'));
        optionList.add(new SelectOption('Workflow Rules', 'Workflow Rules'));
        optionList.add(new SelectOption('Validation Rules', 'Validation Rules'));
        optionList.add(new SelectOption('Flows', 'Flows'));
        optionList.add(new SelectOption('Process Builders', 'Process Builder'));
        optionList.add(new SelectOption('Triggers', 'Triggers'));
        optionList.add(new SelectOption('Lightning Aura Components', 'Aura Components'));
        optionList.add(new SelectOption('Lightning Pages', 'Lightning Pages'));
        optionList.add(new SelectOption('Buttons & Quick Actions', 'Buttons & Quick Actions'));
        optionList.add(new SelectOption('Custom Settings', 'Custom Setting'));
        optionList.add(new SelectOption('Custom Metadata Types', 'MetaDataObjects'));
        
        optionList.sort();

        return optionList;
    }

    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getSelectedMetaDataItems(String selectedMetaDataOption) {
        if(String.isBlank(selectedMetaDataOption)){
            AuraHandledException auraExp = new AuraHandledException('Invalid Metadata Name');
            auraExp.setMessage('Invalid Metadata Name');
            throw auraExp;
        }
        List<SelectOption> optionList = new List<SelectOption>();
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/setup/';
        switch on selectedMetaDataOption {
            when 'Apex Class' {
                for(ApexClass record : [SELECT ID, Name FROM ApexClass Order By Name]){
                    optionList.add(new SelectOption(record.Name , baseURL + 'ApexClasses/page?address=/' + record.Id));
                }
            }
            when 'Layout' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name, EntityDefinition.DeveloperName FROM Layout ORDER BY Name');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, baseURL + 'ObjectManager/' + (metRes.entityDefinition != null ? metRes.entityDefinition.DeveloperName : '') + '/PageLayouts/' + metRes.Id +'/view'));
                }
            }
            when 'Apex Pages' {
                for(ApexPage record : [SELECT ID, Name, MasterLabel FROM ApexPage ORDER BY Name]){
                    String label = String.format(labelToDisplay, new List<String> {record.MasterLabel, record.Name});   
                    optionList.add(new SelectOption(label, baseURL + 'ApexPages/page?address=/' + record.Id));
                }
            }
            
            when 'Static Resources' {
                for(StaticResource record : [SELECT ID, Name FROM StaticResource ORDER BY Name]){    
                    optionList.add(new SelectOption(record.Name, baseURL + 'StaticResources/page?address=/' + record.Id));
                }
            }
            when 'Visualforce Components' {
                for(ApexComponent record : [SELECT ID, Name, MasterLabel FROM ApexComponent ORDER BY Name]){
                    String label = String.format(labelToDisplay, new List<String> {record.MasterLabel, record.Name}); 
                    optionList.add(new SelectOption(label, baseURL + 'ApexComponents/page?address=/' + record.Id));
                }
            }
            when 'Objects' {
                for(Schema.SobjectType record : Schema.getGlobalDescribe().values()){
                    if(!(record.getDescribe().getName().containsIgnoreCase('Feed') ||
                        (record.getDescribe().getName().containsIgnoreCase('History')) ||
                        record.getDescribe().getName().containsIgnoreCase('Authorization') && !record.getDescribe().isCustom())
                        && !record.getDescribe().getName().endsWith('__mdt')
                        && !record.getDescribe().isCustomSetting()) {
                        String label = String.format(labelToDisplay, new List<String> {record.getDescribe().getLabel(), record.getDescribe().getName()}); 
                        optionList.add(new SelectOption(label, baseURL + 'ObjectManager/' + record.getDescribe().getName() + '/Details/view'));
                    }
                }
            }
            when 'Custom Setting' {
                Map<String, Id> mapDevNameCustomObjectId = new Map<String, Id>();
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DeveloperName, NamespacePrefix FROM CustomObject');
                for(MetaDataRecords metRes : metaResults.records){
                    if(String.isNotBlank(metRes.NamespacePrefix)) {
                        mapDevNameCustomObjectId.put((metRes.NamespacePrefix + '__' + metRes.DeveloperName + '__c').toLowerCase(), metRes.Id);
                    } else {
                        mapDevNameCustomObjectId.put((metRes.DeveloperName + '__c').toLowerCase(), metRes.Id);
                    }
                }
                for(Schema.SobjectType record : Schema.getGlobalDescribe().values()){
                    if(record.getDescribe().isCustomSetting()) {
                        String label = String.format(labelToDisplay, new List<String> {record.getDescribe().getLabel(), record.getDescribe().getName()}); 
                        optionList.add(new SelectOption(label, baseURL + 'CustomSettings/page?address=/' + mapDevNameCustomObjectId.get(record.getDescribe().getName().toLowerCase())));
                    }
                }
            }
            when 'MetaDataObjects' {
                Map<String, Id> mapDevNameCustomObjectId = new Map<String, Id>();
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DeveloperName, NamespacePrefix FROM CustomObject');
                for(MetaDataRecords metRes : metaResults.records){
                    if(String.isNotBlank(metRes.NamespacePrefix)) {
                        mapDevNameCustomObjectId.put((metRes.NamespacePrefix + '__' + metRes.DeveloperName + '__mdt').toLowerCase(), metRes.Id);
                    } else {
                        mapDevNameCustomObjectId.put((metRes.DeveloperName + '__mdt').toLowerCase(), metRes.Id);
                    }
                }
                for(Schema.SobjectType record : Schema.getGlobalDescribe().values()){
                    if(record.getDescribe().getName().endsWith('__mdt')) {
                        String label = String.format(labelToDisplay, new List<String> {record.getDescribe().getLabel(), record.getDescribe().getName()});
                        optionList.add(new SelectOption(label, baseURL + 'CustomMetadata/page?address=/' + mapDevNameCustomObjectId.get(record.getDescribe().getName().toLowerCase())));
                    }
                }
            }
            when 'Email Templates' {
                for(EmailTemplate record : [SELECT ID, Name,DeveloperName FROM EmailTemplate ORDER BY Name]){
                    String label = String.format(labelToDisplay, new List<String> {record.Name, record.DeveloperName}); 
                    optionList.add(new SelectOption(label, baseURL + 'CommunicationTemplatesEmail/page?address=/' + record.Id));
                }
            }
            when 'Workflow Rules' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, Name FROM WorkflowRule ORDER BY Name');
                for(MetaDataRecords metRes : metaResults.records){
                    optionList.add(new SelectOption(metRes.Name, baseURL + 'WorkflowRules/page?nodeId=WorkflowRules&address=/' + metRes.Id));
                }
            }
            when 'Validation Rules' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, ValidationName,EntityDefinition.DeveloperName FROM ValidationRule ORDER BY ValidationName');
                for(MetaDataRecords metRes : metaResults.records){
                    String label = String.format(labelToDisplay, new List<String> {metRes.ValidationName, metRes.EntityDefinition.DeveloperName});
                    optionList.add(new SelectOption(label, baseURL + 'ObjectManager/'+ metRes.entityDefinition.DeveloperName
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
                Set<Id> definationSet = new Set<Id>();
                for(MetaDataRecords metRes : metaResults.records){
                    if(!definationSet.contains(metRes.definitionID)){
                        definationSet.add(metRes.definitionID);
                        optionList.add(new SelectOption(metRes.MasterLabel, baseURL + 'InteractionProcesses/page?address=/' + metRes.definitionID));
                    }
                }
            }
            when 'Triggers' {
                for(ApexTrigger record : [SELECT ID, Name FROM ApexTrigger Order By Name]){    
                    optionList.add(new SelectOption(record.Name, baseURL + 'ApexClasses/page?address=/' + record.Id));
                }
            }
            when 'Aura Components' {
                for(AuraDefinitionBundle record : [SELECT ID, DeveloperName FROM AuraDefinitionBundle Order By MasterLabel]){    
                    optionList.add(new SelectOption(record.DeveloperName, baseURL + 'LightningComponentBundles/page?address=/' + record.Id));
                }
            }
            when 'Lightning Pages' {
                MetadataResponseWrapper metaResults = retrieveFromToolingApi('SELECT Id, DeveloperName, MasterLabel FROM FlexiPage ORDER BY MasterLabel');
                for(MetaDataRecords metRes : metaResults.records){
                    String label = String.format(labelToDisplay, new List<String> {metRes.MasterLabel, metRes.DeveloperName});
                    optionList.add(new SelectOption(label, baseURL + 'FlexiPageList/page?address=/' + metRes.Id));
                }
            }
            when 'Buttons & Quick Actions' {
                for(WebLink record : [SELECT ID, Name, PageOrSobjectType, MasterLabel FROM WebLink Order By MasterLabel]){
                    String label = String.format(labelToDisplay, new List<String> {record.MasterLabel, record.Name});
                    optionList.add(new SelectOption(label, baseURL + 'ObjectManager/' + record.PageOrSobjectType + 
                                                                        '/ButtonsLinksActions/'+ record.Id+'/view'));
                }
            }
            
        }
        optionList.sort();
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
        @AuraEnabled public String NamespacePrefix;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public String validationName;
        @AuraEnabled public Integer versionNumber;
        @AuraEnabled public cls_EntityDefinition entityDefinition;
    }
    public class cls_EntityDefinition {
        @AuraEnabled public String DeveloperName;
        @AuraEnabled public String Name;
    }
    
    public class SelectOption implements Comparable {
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
        public Integer compareTo(Object compareTo) {
            SelectOption compareToValue = (SelectOption) compareTo;
            if (this.label == compareToValue.label) return 0;
            if (this.label > compareToValue.label) return 1;
            return -1;
        }
    }
}