public without sharing class TwilioRecieveSMSController {
    
    @TestVisible
    private String strReplyMsg {get; set;}      
    private String fromNumber {get; set;}
    private String toNumber {get; set;} 
    private String body {get; set;}
    public String twiml {get; set;}
    
    public TwilioRecieveSMSController(){
        fromNumber      = ApexPages.currentPage().getParameters().get('From');
        toNumber        = ApexPages.currentPage().getParameters().get('To');
        body            = ApexPages.currentPage().getParameters().get('Body');
    }
    
    public void init(){    
        Set<String> setFromNumbers = new Set<String>();
         if(String.isNotBlank(fromNumber)){            
            try{
            
                body = body.toLowerCase().trim();
                setFromNumbers.add(fromNumber);
                Integer fromNumberLen = fromNumber.length();
                
                if(fromNumberLen > 10){      
                    String fromNumber10DigitFormat = fromNumber.subString(fromNumberLen-10,fromNumberLen);
                    setFromNumbers.add('(' + fromNumber10DigitFormat.subString(0,3) + ') ' +  fromNumber10DigitFormat.subString(3,6) + '-' + fromNumber10DigitFormat.subString(6,10));
                }
                System.debug('setFromNumbers : ' + setFromNumbers);
                
                if((body.equalsIgnoreCase('yes') || body.equalsIgnoreCase('no'))){
                    
                    List<Contact> listConsultants = [SELECT Id FROM Contact WHERE Phone IN :setFromNumbers LIMIT 2];
                    if(listConsultants != NULL && listConsultants.size() == 1){
                        
                        List<Eligible_Consultant__c> listEligibleConsultant = [SELECT Id, Interested__c 
                                                                               FROM Eligible_Consultant__c 
                                                                               WHERE Consultant__c = :listConsultants[0].Id 
                                                                               ORDER BY LastModifiedDate DESC
                                                                               LIMIT 1];
                        if(listEligibleConsultant == NULL || listEligibleConsultant.isEmpty()){
                            strReplyMsg = 'Eligible Consultant record not found.'; 
                        }
                        else if(body.equalsIgnoreCase('yes') && !listEligibleConsultant.isEmpty()){
                            listEligibleConsultant[0].Interested__c = 'Yes';  
                            update listEligibleConsultant[0];
                            strReplyMsg = 'Thank you for your reply.';           
                        }
                        else if(body.equalsIgnoreCase('no') && !listEligibleConsultant.isEmpty()){
                            listEligibleConsultant[0].Interested__c = 'No'; 
                            update listEligibleConsultant[0];
                            strReplyMsg = 'Thank you for your reply.';   
                        }                                               
                    }
                    else if(listConsultants.size() > 1){
                        strReplyMsg = 'More than one Consultant with Phone(' + fromNumber + ') found.';
                    }
                    else if(listConsultants.size() == 0){
                        strReplyMsg = 'Consultant with Phone(' + fromNumber + ') not found.';
                    }
                }else{
                    strReplyMsg = 'Invalid reply!!!.\nPlease reply with YES or NO.';
                }
            }catch(Exception e){
                System.debug('Error - ' + e.getStackTraceString());
                System.debug('Error - ' + e.getLineNumber() + ' --- ' + e.getMessage());
                strReplyMsg = 'Error while creating reply.';// + e.getLineNumber() + ' --- ' + e.getMessage();
            }
        }
        
        TwilioTwiML.Response res = new TwilioTwiML.Response();
        res.append(new TwilioTwiML.SMS(strReplyMsg));
        //res.append(
        //  new TwilioTwiML.Play('http://demo.twilio.com/hellomonkey/monkey.mp3'));
        //res.append(new TwilioTwiML.Hangup());
        twiml = res.toXML();        
    }

}