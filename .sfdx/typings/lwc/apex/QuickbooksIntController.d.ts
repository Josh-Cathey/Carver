declare module "@salesforce/apex/QuickbooksIntController.saveKeyAndSecret" {
  export default function saveKeyAndSecret(param: {clientId: any, clientSecret: any}): Promise<any>;
}
declare module "@salesforce/apex/QuickbooksIntController.getAuthDone" {
  export default function getAuthDone(param: {redirect_URI: any, authCodeFromURL: any}): Promise<any>;
}
