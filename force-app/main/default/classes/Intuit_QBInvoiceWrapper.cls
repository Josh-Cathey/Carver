/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    12 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
public with sharing class Intuit_QBInvoiceWrapper {
    public QueryResponse queryResponse;

    public class QueryResponse {
        public List<Invoice> Invoice;
        public Integer startPosition;
        public Integer maxResults;
        public Integer totalCount;
    }

    public class Invoice {
        public boolean AllowIPNPayment;
        public boolean AllowOnlinePayment;
        public boolean AllowOnlineCreditCardPayment;
        public boolean AllowOnlineACHPayment;
        public String domain;
        public boolean sparse;
        public String Id;
        public String SyncToken;

        public MetaData metaData;
        public List<CustomField> Customfield;
        public String DocNumber;
        public Date TxnDate;
        public CurrencyRef currencyRef;
        public List<LinkedTxn> linkedTxn;
        public List<Line> line;
        public TxnTaxDetail txnTaxDetail;
        public CustomerRef customerRef;
        public CustomerMemo customerMemo;
        public BillAddr billAddr;
        public ShipAddr ShipAddr;
        public boolean freeFormAddress;
        public SalesTermRef salesTermRef;
        public Date DueDate;
        public Decimal TotalAmt;
        public Boolean ApplyTaxAfterDiscount;
        public String PrintStatus;
        public String EmailStatus;
        public BillEmail billEmail;
        public Decimal Balance;



    }

    public class MetaData {
        public string CreateTime;
        public LastModifiedRef lastModifiedRef;
        public String LastUpdatedTime;
    }

    public class LastModifiedRef {
        public String value;
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

    public class LinkedTxn {
        public String TxnId;
        public String TxnType;
    }

    public class Line {
        public String id;
        public String LineNum;
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public SalesItemLineDetail salesItemLineDetail;
        public SubTotalLineDetail subTotalLineDetail;
    }

    public class SalesItemLineDetail {
        public ItemRef ItemRef;
        public Decimal UnitPrice;
        public Integer Qty;
        public ItemAccountRef itemAccountRef;
        public TaxCodeRef TaxCodeRef;
    }

    public class ItemRef {
        public String value;
        public String name;
    }

    public class ItemAccountRef {
        public String value;
        public String name;
    }

    public class TaxCodeRef {
        public String value;
    }
    public class SubTotalLineDetail{
    }
    public class TxnTaxDetail {
        public decimal TotalTax;
    }
    public class CustomerRef {
        public String value;
        public String name;
    }

    public class CustomerMemo {
        public String Value;
    }

    public class BillAddr {
        public String Id;
        public String Line1;
        public String Line2;
        public String Line3;
    }

    public class ShipAddr {
        public String Id;
        public String Line1;
        public String City;
        public String CountrySubDivisionCode;
        public String PostalCode;
    }

    public class SalesTermRef {
        public String value;
        public String name;
    }

    public class BillEmail {
        public String Address;
    }

    public static Intuit_QBInvoiceWrapper jsonParse(String JsonBody){
        Intuit_QBInvoiceWrapper wrap;

        try {
            wrap = (Intuit_QBInvoiceWrapper) JSON.deserialize(jsonbody, Intuit_QBInvoiceWrapper.class);
        }
        catch(Exception e) {
            System.debug('Exception Caught Json Parsing Response: ' + e.getMessage());
            throw e;
        }
        return wrap;
    }


    ///Listen to Webhooks, for any change on Invoice: Grab this QB ID and query SF and see if a invoice number exist for this record.
    // If invoice_number__c doesnt' exist --> generate a number(an incremental field)  and append 'S' before to the Invoice_Number__c
    //make callout to QB to update this same record with this new DocNumber;

    //This Docnumber alteration is the only thing we want from this function, no invoice creation.

}