/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    12 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
public class Intuit_QBCreditMemoWrapper {
    public QueryResponse queryResponse;

    public class QueryResponse {
        public List<CreditMemo> CreditMemo;
        public Integer startPosition;
        public Integer maxResults;
        public Integer totalCount;
    }

    public class CreditMemo {
        public Decimal RemainingCredit;
        public String domain;
        public Boolean sparse;
        public String Id;
        public String SyncToken;
        public MetaData MetaData;
        public List<CustomField> CustomField;
        public String DocNumber;
        public String TxnDate;
        public CurrencyRef currencyRef;
        public List<Line> line;
        public TxnTaxDetail TxnTaxDetail;
        public CustomerRef CustomerRef;
        public CustomerMemo CustomerMemo;
        public BillAddr billAddr;
        public ShipAddr shipAddr;
        public boolean FreeFormAddress;
        public Decimal TotalAmt;
        public boolean ApplyTaxAfterDiscount;
        public String PrintStatus;
        public String EmailStatus;
        public BillEmail billEmail;
        public Decimal balance;
    }

    public class MetaData {
        public String CreateTime;
        public String LastUpdatedTime;
    }

    public class CustomField {
        public String DefinitionId;
        public String Name;
        public String Type;
    }

    public class CurrencyRef {
        public String value;
        public String name;
    }

    public class Line {
        public String Id;
        public Integer LineNum;
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public SalesItemLineDetail salesItemLineDetail;
    }

    public class SalesItemLineDetail {
        public ItemRef itemRef;
        public Decimal UnitPrice;
        public Integer Qty;
        public ItemAccountRef itemAccountRef;
        public TaxCodeRef taxCodeRef;
    }

    public class ItemRef {
        public String Value;
        public String Name;
    }

    public class ItemAccountRef {
        public String value;
        public String name;
    }

    public class TaxCodeRef {
        public String value;
    }

    public class TxnTaxDetail {
        public Decimal TotalTax;
    }

    public class CustomerRef {
        public String value;
        public String name;
    }

    public class CustomerMemo {
        public String value;
    }

    public class BillAddr {
        public String id;
        public String Line1;
        public String Line2;
        public String Line3;
        public String Line4;
    }

    public class ShipAddr {
        public String id;
        public String Line1;
        public String City;
        public String CountrySubDivisionCode;
        public String PostalCode;
    }

    public class BillEmail {
        public String Address;
    }

    public static Intuit_QBCreditMemoWrapper jsonParse(String JsonBody){
        Intuit_QBCreditMemoWrapper wrap;

        try {
            wrap = (Intuit_QBCreditMemoWrapper) JSON.deserialize(jsonbody, Intuit_QBCreditMemoWrapper.class);
        }
        catch(Exception e) {
            System.debug('Exception Caught Json Parsing Response: ' + e.getMessage());
            throw e;
        }
        return wrap;
    }
}