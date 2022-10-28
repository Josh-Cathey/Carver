/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    11 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public class Intuit_MockResponse {

    public static HttpResponse getQBCustomerFullResp() {
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody(
                '{' +
                '                "QueryResponse": {' +
                '                "Customer": [' +
                '                {' +
                '                "Taxable": false,' +
                '                "BillAddr": {' +
                '                "Id": "5",' +
                '                "Line1": "321 Channing",' +
                '                "City": "Palo Alto",' +
                '                "CountrySubDivisionCode": "CA",' +
                '                "PostalCode": "94303",' +
                '                "Lat": "37.443231",' +
                '                "Long": "-122.1561846"' +
                '            },' +
                '            "Job": false,' +
                '                    "BillWithParent": false,' +
                '                    "Balance": 0,' +
                '                    "BalanceWithJobs": 0,' +
                '                    "CurrencyRef": {' +
                '                "value": "USD",' +
                '                "name": "United States Dollar"' +
                '            },' +
                '            "PreferredDeliveryMethod": "Print",' +
                '                    "IsProject": false,' +
                '                    "ClientEntityId": "0",' +
                '                    "domain": "QBO",' +
                '                    "sparse": false,' +
                '                    "Id": "4",' +
                '                    "SyncToken": "0",' +
                '                    "MetaData": {' +
                '                "CreateTime": "2022-07-02T16:52:08-07:00",' +
                '                "LastUpdatedTime": "2022-07-02T16:52:08-07:00"' +
                '            },' +
                '            "GivenName": "Diego",' +
                '                    "FamilyName": "Rodriguez",' +
                '                    "FullyQualifiedName": "Diego Rodriguez",' +
                '                    "DisplayName": "Diego Rodriguez",' +
                '                    "PrintOnCheckName": "Diego Rodriguez",' +
                '                    "Active": true,' +
                '                    "V4IDPseudonym": "0020981310ae733dc440909cfb88224b6799c4",' +
                '                    "PrimaryPhone": {' +
                '                "FreeFormNumber": "(650) 555-4477"' +
                '            },' +
                '            "PrimaryEmailAddr": {' +
                '                "Address": "Diego@Rodriguez.com"' +
                '            }}]}' +
                '        }');
        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;
    }
    public static HttpResponse getQBInvoiceFullResp(){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{' +
                '    "QueryResponse": {' +
                '        "Invoice": [' +
                '            {' +
                '                "AllowIPNPayment": false,' +
                '                "AllowOnlinePayment": false,' +
                '                "AllowOnlineCreditCardPayment": false,' +
                '                "AllowOnlineACHPayment": false,' +
                '                "domain": "QBO",' +
                '                "sparse": false,' +
                '                "Id": "16",' +
                '                "SyncToken": "1",' +
                '                "MetaData": {' +
                '                    "CreateTime": "2022-07-07T15:10:40-07:00",' +
                '                    "LastModifiedByRef": {' +
                '                        "value": "9130354553948956"' +
                '                    },' +
                '                    "LastUpdatedTime": "2022-07-08T11:06:49-07:00"' +
                '                },' +
                '                "CustomField": [' +
                '                    {' +
                '                        "DefinitionId": "1",' +
                '                        "Name": "Crew #",' +
                '                        "Type": "StringType"' +
                '                    }' +
                '                ],' +
                '                "DocNumber": "1007",' +
                '                "TxnDate": "2022-06-15",' +
                '                "CurrencyRef": {' +
                '                    "value": "USD",' +
                '                    "name": "United States Dollar"' +
                '                },' +
                '                "LinkedTxn": [' +
                '                    {' +
                '                        "TxnId": "32",' +
                '                        "TxnType": "Payment"' +
                '                    }' +
                '                ],' +
                '                "Line": [' +
                '                    {' +
                '                        "Id": "1",' +
                '                        "LineNum": 1,' +
                '                        "Description": "Custom Design",' +
                '                        "Amount": 750.00,' +
                '                        "DetailType": "SalesItemLineDetail",' +
                '                        "SalesItemLineDetail": {' +
                '                            "ItemRef": {' +
                '                                "value": "4",' +
                '                                "name": "Design"' +
                '                            },' +
                '                            "UnitPrice": 75,' +
                '                            "Qty": 10,' +
                '                            "ItemAccountRef": {' +
                '                                "value": "82",' +
                '                                "name": "Design income"' +
                '                            },' +
                '                            "TaxCodeRef": {' +
                '                                "value": "NON"' +
                '                            }' +
                '                        }' +
                '                    },' +
                '                    {' +
                '                        "Amount": 750.00,' +
                '                        "DetailType": "SubTotalLineDetail",' +
                '                        "SubTotalLineDetail": {}' +
                '                    }' +
                '                ],' +
                '                "TxnTaxDetail": {' +
                '                    "TotalTax": 0' +
                '                },' +
                '                "CustomerRef": {' +
                '                    "value": "13",' +
                '                    "name": "John Melton"' +
                '                },' +
                '                "CustomerMemo": {' +
                '                    "value": "Thank you for your business and have a great day!"' +
                '                },' +
                '                "BillAddr": {' +
                '                    "Id": "53",' +
                '                    "Line1": "John Melton",' +
                '                    "Line2": "85 Pine St.",' +
                '                    "Line3": "Menlo Park, CA  94304",' +
                '                    "Lat": "37.3813444",' +
                '                    "Long": "-122.1802812"' +
                '                },' +
                '                "ShipAddr": {' +
                '                    "Id": "13",' +
                '                    "Line1": "85 Pine St.",' +
                '                    "City": "Menlo Park",' +
                '                    "CountrySubDivisionCode": "CA",' +
                '                    "PostalCode": "94304",' +
                '                    "Lat": "37.4451342",' +
                '                    "Long": "-122.1409626"' +
                '                },' +
                '                "FreeFormAddress": true,' +
                '                "SalesTermRef": {' +
                '                    "value": "3",' +
                '                    "name": "Net 30"' +
                '                },' +
                '                "DueDate": "2022-07-15",' +
                '                "TotalAmt": 750.00,' +
                '                "ApplyTaxAfterDiscount": false,' +
                '                "PrintStatus": "NeedToPrint",' +
                '                "EmailStatus": "NotSet",' +
                '                "BillEmail": {' +
                '                    "Address": "John@Melton.com"' +
                '                },' +
                '                "Balance": 450.00' +
                '            }' +
                '        ],' +
                '        "startPosition": 1,' +
                '        "maxResults": 1,' +
                '        "totalCount": 1' +
                '    },' +
                '    "time": "2022-10-11T05:58:57.612-07:00"' +
                '}');

        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;

    }
    public static HttpResponse getQBPaymentFullResp(){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{' +
                '    "QueryResponse": {' +
                '        "Payment": [' +
                '            {' +
                '                "CustomerRef": {' +
                '                    "value": "13",' +
                '                    "name": "John Melton"' +
                '                },' +
                '                "DepositToAccountRef": {' +
                '                    "value": "4"' +
                '                },' +
                '                "PaymentMethodRef": {' +
                '                    "value": "2"' +
                '                },' +
                '                "PaymentRefNum": "5421",' +
                '                "TotalAmt": 300.00,' +
                '                "UnappliedAmt": 0,' +
                '                "ProcessPayment": false,' +
                '                "domain": "QBO",' +
                '                "sparse": false,' +
                '                "Id": "32",' +
                '                "SyncToken": "0",' +
                '                "MetaData": {' +
                '                    "CreateTime": "2022-07-08T11:06:49-07:00",' +
                '                    "LastUpdatedTime": "2022-07-08T11:06:49-07:00"' +
                '                },' +
                '                "TxnDate": "2022-07-08",' +
                '                "CurrencyRef": {' +
                '                    "value": "USD",' +
                '                    "name": "United States Dollar"' +
                '                },' +
                '                "LinkedTxn": [' +
                '                    {' +
                '                        "TxnId": "102",' +
                '                        "TxnType": "Deposit"' +
                '                    }' +
                '                ],' +
                '                "Line": [' +
                '                    {' +
                '                        "Amount": 300.00,' +
                '                        "LinkedTxn": [' +
                '                            {' +
                '                                "TxnId": "16",' +
                '                                "TxnType": "Invoice"' +
                '                            }' +
                '                        ],' +
                '                        "LineEx": {' +
                '                            "any": [' +
                '                                {' +
                '                                    "name": "{http://schema.intuit.com/finance/v3}NameValue",' +
                '                                    "declaredType": "com.intuit.schema.finance.v3.NameValue",' +
                '                                    "scope": "javax.xml.bind.JAXBElement$GlobalScope",' +
                '                                    "value": {' +
                '                                        "Name": "txnId",' +
                '                                        "Value": "16"' +
                '                                    },' +
                '                                    "nil": false,' +
                '                                    "typeSubstituted": false,' +
                '                                    "globalScope": true' +
                '                                },' +
                '                                {' +
                '                                    "name": "{http://schema.intuit.com/finance/v3}NameValue",' +
                '                                    "declaredType": "com.intuit.schema.finance.v3.NameValue",' +
                '                                    "scope": "javax.xml.bind.JAXBElement$GlobalScope",' +
                '                                    "value": {' +
                '                                        "Name": "txnOpenBalance",' +
                '                                        "Value": "750.00"' +
                '                                    },' +
                '                                    "nil": false,' +
                '                                    "typeSubstituted": false,' +
                '                                    "globalScope": true' +
                '                                },' +
                '                                {' +
                '                                    "name": "{http://schema.intuit.com/finance/v3}NameValue",' +
                '                                    "declaredType": "com.intuit.schema.finance.v3.NameValue",' +
                '                                    "scope": "javax.xml.bind.JAXBElement$GlobalScope",' +
                '                                    "value": {' +
                '                                        "Name": "txnReferenceNumber",' +
                '                                        "Value": "1007"' +
                '                                    },' +
                '                                    "nil": false,' +
                '                                    "typeSubstituted": false,' +
                '                                    "globalScope": true' +
                '                                }' +
                '                            ]' +
                '                        }' +
                '                    }' +
                '                ]' +
                '            }' +
                '                ' +
                '            ' +
                '        ],' +
                '        "startPosition": 1,' +
                '        "maxResults": 1' +
                '    },' +
                '    "time": "2022-10-11T05:54:36.577-07:00"' +
                '}');

        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;

    }
    public static HttpResponse getQBCreditMemoFullResp(){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{' +
                '    "QueryResponse": {' +
                '        "CreditMemo": [' +
                '            {' +
                '                "RemainingCredit": 0,' +
                '                "domain": "QBO",' +
                '                "sparse": false,' +
                '                "Id": "73",' +
                '                "SyncToken": "1",' +
                '                "MetaData": {' +
                '                    "CreateTime": "2022-07-09T12:51:27-07:00",' +
                '                    "LastUpdatedTime": "2022-07-09T12:51:28-07:00"' +
                '                },' +
                '                "CustomField": [' +
                '                    {' +
                '                        "DefinitionId": "1",' +
                '                        "Name": "Crew #",' +
                '                        "Type": "StringType"' +
                '                    }' +
                '                ],' +
                '                "DocNumber": "1026",' +
                '                "TxnDate": "2022-06-23",' +
                '                "CurrencyRef": {' +
                '                    "value": "USD",' +
                '                    "name": "United States Dollar"' +
                '                },' +
                '                "Line": [' +
                '                    {' +
                '                        "Id": "1",' +
                '                        "LineNum": 1,' +
                '                        "Description": "Pest Control Services",' +
                '                        "Amount": 100.00,' +
                '                        "DetailType": "SalesItemLineDetail",' +
                '                        "SalesItemLineDetail": {' +
                '                            "ItemRef": {' +
                '                                "value": "10",' +
                '                                "name": "Pest Control"' +
                '                            },' +
                '                            "UnitPrice": 100,' +
                '                            "Qty": 1,' +
                '                            "ItemAccountRef": {' +
                '                                "value": "54",' +
                '                                "name": "Pest Control Services"' +
                '                            },' +
                '                            "TaxCodeRef": {' +
                '                                "value": "NON"' +
                '                            }' +
                '                        }' +
                '                    },' +
                '                    {' +
                '                        "Amount": 100.00,' +
                '                        "DetailType": "SubTotalLineDetail",' +
                '                        "SubTotalLineDetail": {}' +
                '                    }' +
                '                ],' +
                '                "TxnTaxDetail": {' +
                '                    "TotalTax": 0' +
                '                },' +
                '                "CustomerRef": {' +
                '                    "value": "1",' +
                '                    "name": "Amy\'s Bird Sanctuary"' +
                '                },' +
                '                "CustomerMemo": {' +
                '                    "value": "Thank you for your business and have a great day!"' +
                '                },' +
                '                "BillAddr": {' +
                '                    "Id": "79",' +
                '                    "Line1": "Amy Lauterbach",' +
                '                    "Line2": "Amy\'s Bird Sanctuary",' +
                '                    "Line3": "4581 Finch St.",' +
                '                    "Line4": "Bayshore, CA  94326",' +
                '                    "Lat": "INVALID",' +
                '                    "Long": "INVALID"' +
                '                },' +
                '                "ShipAddr": {' +
                '                    "Id": "2",' +
                '                    "Line1": "4581 Finch St.",' +
                '                    "City": "Bayshore",' +
                '                    "CountrySubDivisionCode": "CA",' +
                '                    "PostalCode": "94326",' +
                '                    "Lat": "INVALID",' +
                '                    "Long": "INVALID"' +
                '                },' +
                '                "FreeFormAddress": true,' +
                '                "TotalAmt": 100.00,' +
                '                "ApplyTaxAfterDiscount": false,' +
                '                "PrintStatus": "NeedToPrint",' +
                '                "EmailStatus": "NotSet",' +
                '                "BillEmail": {' +
                '                    "Address": "Birds@Intuit.com"' +
                '                },' +
                '                "Balance": 0' +
                '            }' +
                '        ],' +
                '        "startPosition": 1,' +
                '        "maxResults": 1' +
                '    },' +
                '    "time": "2022-10-11T05:58:38.407-07:00"' +
                '}');

        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;

    }
    public static HttpResponse getQBWebhook() {
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody(
                '{   "eventNotifications":[' +
                '   {' +
                '      "realmId":"1185883450",' +
                '      "dataChangeEvent":' +
                '      {' +
                '         "entities":[' +
                '         {' +
                '            "name":"Customer",' +
                '            "id":"1",' +
                '            "operation":"Create",' +
                '            "lastUpdated":"2015-10-05T14:42:19-0700"' +
                '         },' +
                '         {' +
                '            "name":"Vendor",' +
                '            "id":"1",' +
                '            "operation":"Create",' +
                '            "lastUpdated":"2015-10-05T14:42:19-0700"' +
                '         }]' +
                '      }' +
                '   }]' +
                '}');
        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;
    }
    public static HttpResponse getQBReadInvoiceResp(){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{' +
                '    "Invoice": {' +
                '        "AllowIPNPayment": false,' +
                '        "AllowOnlinePayment": false,' +
                '        "AllowOnlineCreditCardPayment": false,' +
                '        "AllowOnlineACHPayment": false,' +
                '        "InvoiceLink": "https://developer.intuit.com/comingSoonview/scs-v1-0967d169cccc4fa6aa322cf9803e13da4936af84b52040e89c5c52052aefb34088e1d342a01a43d0b1b52717e13c0c2e?locale=en_US&cta=v3invoicelink",' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "130",' +
                '        "SyncToken": "9",' +
                '        "MetaData": {' +
                '            "CreateTime": "2022-07-10T13:16:17-07:00",' +
                '            "LastModifiedByRef": {' +
                '                "value": "9130354553948956"' +
                '            },' +
                '            "LastUpdatedTime": "2022-07-10T13:16:17-07:00"' +
                '        },' +
                '        "CustomField": [' +
                '            {' +
                '                "DefinitionId": "1",' +
                '                "Name": "Crew #",' +
                '                "Type": "StringType",' +
                '                "StringValue": "102"' +
                '            }' +
                '        ],' +
                '        "DocNumber": "1037",' +
                '        "TxnDate": "2022-07-10",' +
                '        "CurrencyRef": {' +
                '            "value": "USD",' +
                '            "name": "United States Dollar"' +
                '        },' +
                '        "LinkedTxn": [' +
                '            {' +
                '                "TxnId": "100",' +
                '                "TxnType": "Estimate"' +
                '            }' +
                '        ],' +
                '        "Line": [' +
                '            {' +
                '                "Id": "1",' +
                '                "LineNum": 1,' +
                '                "Description": "Rock Fountain",' +
                '                "Amount": 275.00,' +
                '                "LinkedTxn": [' +
                '                    {' +
                '                        "TxnId": "100",' +
                '                        "TxnType": "Estimate"' +
                '                    }' +
                '                ],' +
                '                "DetailType": "SalesItemLineDetail",' +
                '                "SalesItemLineDetail": {' +
                '                    "ItemRef": {' +
                '                        "value": "5",' +
                '                        "name": "Rock Fountain"' +
                '                    },' +
                '                    "UnitPrice": 275,' +
                '                    "Qty": 1,' +
                '                    "ItemAccountRef": {' +
                '                        "value": "79",' +
                '                        "name": "Sales of Product Income"' +
                '                    },' +
                '                    "TaxCodeRef": {' +
                '                        "value": "TAX"' +
                '                    }' +
                '                }' +
                '            },' +
                '            {' +
                '                "Id": "2",' +
                '                "LineNum": 2,' +
                '                "Description": "Fountain Pump",' +
                '                "Amount": 12.75,' +
                '                "LinkedTxn": [' +
                '                    {' +
                '                        "TxnId": "100",' +
                '                        "TxnType": "Estimate"' +
                '                    }' +
                '                ],' +
                '                "DetailType": "SalesItemLineDetail",' +
                '                "SalesItemLineDetail": {' +
                '                    "ItemRef": {' +
                '                        "value": "11",' +
                '                        "name": "Pump"' +
                '                    },' +
                '                    "UnitPrice": 12.75,' +
                '                    "Qty": 1,' +
                '                    "ItemAccountRef": {' +
                '                        "value": "79",' +
                '                        "name": "Sales of Product Income"' +
                '                    },' +
                '                    "TaxCodeRef": {' +
                '                        "value": "TAX"' +
                '                    }' +
                '                }' +
                '            },' +
                '            {' +
                '                "Id": "3",' +
                '                "LineNum": 3,' +
                '                "Description": "Concrete for fountain installation",' +
                '                "Amount": 47.50,' +
                '                "LinkedTxn": [' +
                '                    {' +
                '                        "TxnId": "100",' +
                '                        "TxnType": "Estimate"' +
                '                    }' +
                '                ],' +
                '                "DetailType": "SalesItemLineDetail",' +
                '                "SalesItemLineDetail": {' +
                '                    "ItemRef": {' +
                '                        "value": "3",' +
                '                        "name": "Concrete"' +
                '                    },' +
                '                    "UnitPrice": 9.5,' +
                '                    "Qty": 5,' +
                '                    "ItemAccountRef": {' +
                '                        "value": "48",' +
                '                        "name": "Landscaping Services:Job Materials:Fountains and Garden Lighting"' +
                '                    },' +
                '                    "TaxCodeRef": {' +
                '                        "value": "TAX"' +
                '                    }' +
                '                }' +
                '            },' +
                '            {' +
                '                "Amount": 335.25,' +
                '                "DetailType": "SubTotalLineDetail",' +
                '                "SubTotalLineDetail": {}' +
                '            }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '            "TxnTaxCodeRef": {' +
                '                "value": "2"' +
                '            },' +
                '            "TotalTax": 26.82,' +
                '            "TaxLine": [' +
                '                {' +
                '                    "Amount": 26.82,' +
                '                    "DetailType": "TaxLineDetail",' +
                '                    "TaxLineDetail": {' +
                '                        "TaxRateRef": {' +
                '                            "value": "3"' +
                '                        },' +
                '                        "PercentBased": true,' +
                '                        "TaxPercent": 8,' +
                '                        "NetAmountTaxable": 335.25' +
                '                    }' +
                '                }' +
                '            ]' +
                '        },' +
                '        "CustomerRef": {' +
                '            "value": "24",' +
                '            "name": "Sonnenschein Family Store"' +
                '        },' +
                '        "CustomerMemo": {' +
                '            "value": "Thank you for your business and have a great day!"' +
                '        },' +
                '        "BillAddr": {' +
                '            "Id": "95",' +
                '            "Line1": "Russ Sonnenschein",' +
                '            "Line2": "Sonnenschein Family Store",' +
                '            "Line3": "5647 Cypress Hill Ave.",' +
                '            "Line4": "Middlefield, CA  94303",' +
                '            "Lat": "37.4238562",' +
                '            "Long": "-122.1141681"' +
                '        },' +
                '        "ShipAddr": {' +
                '            "Id": "25",' +
                '            "Line1": "5647 Cypress Hill Ave.",' +
                '            "City": "Middlefield",' +
                '            "CountrySubDivisionCode": "CA",' +
                '            "PostalCode": "94303",' +
                '            "Lat": "37.4238562",' +
                '            "Long": "-122.1141681"' +
                '        },' +
                '        "FreeFormAddress": true,' +
                '        "SalesTermRef": {' +
                '            "value": "3",' +
                '            "name": "Net 30"' +
                '        },' +
                '        "DueDate": "2022-08-09",' +
                '        "TotalAmt": 362.07,' +
                '        "ApplyTaxAfterDiscount": false,' +
                '        "PrintStatus": "NeedToPrint",' +
                '        "EmailStatus": "NotSet",' +
                '        "BillEmail": {' +
                '            "Address": "Familiystore@intuit.com"' +
                '        },' +
                '        "Balance": 362.07' +
                '    },' +
                '    "time": "2022-10-16T21:24:27.030-07:00"' +
                '}');
        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;
    }
    public static HttpResponse getQBReadCustomerResp(){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('content-type', 'application/json');
        resp.setBody('{\n' +
                '    "Customer": {\n' +
                '        "Taxable": true,\n' +
                '        "BillAddr": {\n' +
                '            "Id": "2",\n' +
                '            "Line1": "4581 Finch St.",\n' +
                '            "City": "Bayshore",\n' +
                '            "CountrySubDivisionCode": "CA",\n' +
                '            "PostalCode": "94326",\n' +
                '            "Lat": "INVALID",\n' +
                '            "Long": "INVALID"\n' +
                '        },\n' +
                '        "ShipAddr": {\n' +
                '            "Id": "2",\n' +
                '            "Line1": "4581 Finch St.",\n' +
                '            "City": "Bayshore",\n' +
                '            "CountrySubDivisionCode": "CA",\n' +
                '            "PostalCode": "94326",\n' +
                '            "Lat": "INVALID",\n' +
                '            "Long": "INVALID"\n' +
                '        },\n' +
                '        "Job": false,\n' +
                '        "BillWithParent": false,\n' +
                '        "Balance": 239.00,\n' +
                '        "BalanceWithJobs": 239.00,\n' +
                '        "CurrencyRef": {\n' +
                '            "value": "USD",\n' +
                '            "name": "United States Dollar"\n' +
                '        },\n' +
                '        "PreferredDeliveryMethod": "Print",\n' +
                '        "IsProject": false,\n' +
                '        "domain": "QBO",\n' +
                '        "sparse": false,\n' +
                '        "Id": "1",\n' +
                '        "SyncToken": "0",\n' +
                '        "MetaData": {\n' +
                '            "CreateTime": "2022-07-02T16:48:43-07:00",\n' +
                '            "LastUpdatedTime": "2022-07-09T13:39:32-07:00"\n' +
                '        },\n' +
                '        "GivenName": "Amy",\n' +
                '        "FamilyName": "Lauterbach",\n' +
                '        "FullyQualifiedName": "Amy\'s Bird Sanctuary",\n' +
                '        "CompanyName": "Amy\'s Bird Sanctuary",\n' +
                '        "DisplayName": "Amy\'s Bird Sanctuary",\n' +
                '        "PrintOnCheckName": "Amy\'s Bird Sanctuary",\n' +
                '        "Active": true,\n' +
                '        "PrimaryPhone": {\n' +
                '            "FreeFormNumber": "(650) 555-3311"\n' +
                '        },\n' +
                '        "PrimaryEmailAddr": {\n' +
                '            "Address": "Birds@Intuit.com"\n' +
                '        },\n' +
                '        "DefaultTaxCodeRef": {\n' +
                '            "value": "2"\n' +
                '        }\n' +
                '    },\n' +
                '    "time": "2022-10-17T01:49:27.754-07:00"\n' +
                '}');
        resp.setStatusCode(200);
        resp.setStatus('OK');
        return resp;
    }
    public static HttpResponse getQBSparseUpdateCustomerResp(){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('content-type', 'application/json');
        resp.setBody('{\n' +
                '    "Customer": {\n' +
                '        "Taxable": false,\n' +
                '        "BillAddr": {\n' +
                '            "Id": "3",\n' +
                '            "Line1": "12 Ocean Dr.",\n' +
                '            "City": "Half Moon Bay",\n' +
                '            "CountrySubDivisionCode": "CA",\n' +
                '            "PostalCode": "94213",\n' +
                '            "Lat": "37.4307072",\n' +
                '            "Long": "-122.4295234"\n' +
                '        },\n' +
                '        "Job": true,\n' +
                '        "BillWithParent": true,\n' +
                '        "ParentRef": {\n' +
                '            "value": "3"\n' +
                '        },\n' +
                '        "Level": 1,\n' +
                '        "Balance": 85.00,\n' +
                '        "BalanceWithJobs": 85.00,\n' +
                '        "CurrencyRef": {\n' +
                '            "value": "USD",\n' +
                '            "name": "United States Dollar"\n' +
                '        },\n' +
                '        "PreferredDeliveryMethod": "Print",\n' +
                '        "IsProject": false,\n' +
                '        "domain": "QBO",\n' +
                '        "sparse": false,\n' +
                '        "Id": "2",\n' +
                '        "SyncToken": "1",\n' +
                '        "MetaData": {\n' +
                '            "CreateTime": "2022-07-02T16:49:28-07:00",\n' +
                '            "LastUpdatedTime": "2022-10-17T02:05:19-07:00"\n' +
                '        },\n' +
                '        "GivenName": "Bill",\n' +
                '        "FamilyName": "Lucchini",\n' +
                '        "FullyQualifiedName": "Cool Cars:Bill\'s Windsurf Shop",\n' +
                '        "CompanyName": "Bill\'s Windsurf Shop",\n' +
                '        "DisplayName": "Bill\'s Windsurf Shop",\n' +
                '        "PrintOnCheckName": "Bill\'s Windsurf Shop",\n' +
                '        "Active": true,\n' +
                '        "PrimaryPhone": {\n' +
                '            "FreeFormNumber": "(415) 444-6538"\n' +
                '        },\n' +
                '        "PrimaryEmailAddr": {\n' +
                '            "Address": "Surf@Intuit.com"\n' +
                '        }\n' +
                '    },\n' +
                '    "time": "2022-10-17T02:05:18.962-07:00"\n' +
                '}');
        resp.setStatus('OK');
        resp.setStatusCode(200);
        return resp;
    }
}