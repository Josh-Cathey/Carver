/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    06 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
public class Intuit_QBCustomerWrapper {
    public QueryResponse QueryResponse;

    public class QueryResponse{
        public List<Customer> Customer;
    }

    public class Customer {
        public String domain;
        public String FamilyName;
        public String DisplayName;
        public DefaultTaxCodeRef DefaultTaxCodeRef;
        public PrimaryEmailAddr PrimaryEmailAddr;
        public string PreferredDeliveryMethod;
        public string GivenName;
        public string FullyQualifiedName;
        public boolean BillWithParent;
        public boolean Job;
        public Decimal BalanceWithJobs;
        public String MiddleName;
        public String Notes;
        public Boolean Taxable;
        public Decimal Balance;
        public String SyncToken;
        public boolean Active;
        public ParentRef parentRef;
        public String PrintOnCheckName;
        public Boolean sparse;
        public String Id;
        public String CompanyName;
        public PrimaryPhone primaryPhone;
        public BillAddr billAddr;
        public ShippAddr shippAddr;
    }

    public class DefaultTaxCodeRef {
        public Integer value;
    }

    public class PrimaryEmailAddr {
        public string Address;
    }

    public class PrimaryPhone {
        public String FreeFormNumber;
    }

    public class MetaData {
        public String CreateTime;
        public String LastUpdatedTime;
    }

    public class parentRef {
        public String value;
    }

    public class BillAddr {
        public String City;
        public String Line1;
        public String PostalCode;
        public String CountrySubDivisionCode;
        public String Id;
    }

    public class ShippAddr {
        public String City;
        public String Line1;
        public String PostalCode;
        public String CountrySubDivisionCode;
        public String Id;
    }

    public static Intuit_QBCustomerWrapper jsonParse(String JsonBody){
        Intuit_QBCustomerWrapper wrap;

        try {
            wrap = (Intuit_QBCustomerWrapper) JSON.deserialize(jsonbody, Intuit_QBCustomerWrapper.class);
        }
        catch(Exception e) {
            System.debug('Exception Caught Json Parsing Response: ' + e.getMessage());
            throw e;
        }
        return wrap;
    }

    //Any update in SF account hierarchy needs to be applied to QB; if there's no matchign account I can skip
    ///Account Trigger before /update-   if oldMap.parentID != newMap.parentID(one parentId change) & parentID !=Null
    //Make a callout to QB for make a update onto QB, to  update: mark job=true & parentRef.Value set to the SF record QUICKBOOK_id


}