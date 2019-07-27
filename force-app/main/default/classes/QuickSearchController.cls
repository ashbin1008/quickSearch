public with sharing class QuickSearchController {
    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getMetaDataOptions() {
        List<Contact> contactList = [SELECT Id, Name  FROM Contact limit 50];
        List<SelectOption> optionList = new List<SelectOption>();
        for(Contact record : contactList) {
            optionList.add(new SelectOption(record.name, record.id));
        }
        return optionList;
    }

    public class SelectOption {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        SelectOption(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }
}