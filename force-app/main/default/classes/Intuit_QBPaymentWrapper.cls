/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    12 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
public class Intuit_QBPaymentWrapper {
    public QueryResponse queryResponse;

    public class QueryResponse {
        public List<Payment> Payment;
        public Integer startPosition;
        public Integer maxResults;
        public Integer totalCount;
    }

    public class Payment {
        public CustomerRef customerRef;
        public DepositToAccountRef depositToAccountRef;
        public PaymentMethodRef paymentMethodRef;
        public Integer PaymentRefNum;
        public Decimal TotalAmt;
        public Decimal UnappliedAmt;
        public Boolean ProcessedPayment;
        public String domain;
        public boolean sparse;
        public String Id;
        public String SyncToken;

        public MetaData metaData;
        public String TxnDate;
        public CurrencyRef currencyRef;
        public List<LinkedTxn> linkedTxn;
        public List<Line> line;

    }
        public class CustomerRef {
            public String value;
            public String name;
        }

        public class DepositToAccountRef {
            public String value;
        }

        public class PaymentMethodRef {
            public String value;
        }

        public class CurrencyRef {
            public String value;
            public String name;
        }

        public class MetaData {
            public String CreateTime;
            public String LastUpdatedTime;
        }

        public class LinkedTxn {
            public String TxnId;
            public String TxnType;
        }

        public class Line {
            public Decimal Amount;
            public List<LinkedTxn> linkedTxn;
            public LineEx lineEx;
        }

        public class LineEx {
            public List<any_c> any_c;
        }

        public class any_c {
            public String name;
            public String declaredType;
            public String scope;
            public Value value;
            public boolean nil;
            public boolean typeSubstituted;
            public boolean globalScope;
        }

        public class Value {
            public String Name;
            public String value;
        }


    public static Intuit_QBPaymentWrapper jsonParse(String JsonBody){
        JsonBody.replace('any', 'any_c');
        Intuit_QBPaymentWrapper wrap;

        try {
            wrap = (Intuit_QBPaymentWrapper) JSON.deserialize(jsonbody, Intuit_QBPaymentWrapper.class);
        }
        catch(Exception e) {
            System.debug('Exception Caught Json Parsing Response: ' + e.getMessage());
            throw e;
        }
        return wrap;
    }
}