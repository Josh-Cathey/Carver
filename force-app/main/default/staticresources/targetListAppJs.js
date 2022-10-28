var targetListApp = angular.module( "targetListApp", [ "ngTable" ] );

targetListApp.factory('remotingFactory', function( $q ){
    DataFactoryObj = {};
    DataFactoryObj.invokeRemoteAction = function( options ) {
        var deferred = $q.defer();
        options.callback = function( result, event ) {    
            console.log("remoting result: ", result);
            console.log( "event status: ",event.status );
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                //console.log(event.message);
                deferred.reject(event.message);
            }
        };
        options.vfConfig = { escape: false };        
        var argumentsArray = [];        
        argumentsArray.push(options.url);        
        for(var i = 0; i < options.params.length; i++){
            argumentsArray.push(options.params[i]);
        }        
        argumentsArray.push(options.callback);        
        argumentsArray.push(options.vfConfig);
        console.log(argumentsArray);
        Visualforce.remoting.Manager.invokeAction.apply(Visualforce.remoting.Manager, argumentsArray);
        return deferred.promise;
    };
    return DataFactoryObj;
});

targetListApp.controller( 'targetListController', function( $scope, remotingFactory, NgTableParams, $filter, $timeout ) {
	var self = this;
	$scope.filters = {
		StateFilter : false,
		familyOfBrandsFilters : false,
		noOfRoomsFilter : false,
        desiredSalary : false
	}
    
    $scope.showError = false;
    
	$scope.dataObj = {
		checkAll : false,
		pageCount : 10,
		showLoader : false,
		showPopupMsg : false,
		popupMessage : '',
		targetList : [],
		tableGlobalSearch : ''
	}
	self.initNgTblGlobalSearch = function( tableParams ) {
        $scope.$watch('dataObj.tableGlobalSearch', function(newTerm, oldTerm) {
            tableParams.reload();
            tableParams.page( 1 );
        }, true);
    }
	self.initTargetListTbl = function() {
		var pgCount = ( $scope.dataObj.pageCount == 'All' ) ? $scope.dataObj.targetList.length : $scope.dataObj.pageCount;
		$scope.dataObj.targetListTblParams = new NgTableParams({
            page: 1,            // show first page
            count: pgCount // count per page
        }, {
            //counts: [ 1, 5, 10, 25, 50, 100 ],
            counts: [ { label : 1, value : 1 }, { label : 5, value : 5 }, { label : 10, value : 10 }, { label : 25, value : 25 }, { label : 50, value : 50 }, { label : 'All', value : 'All' } ],
            total: $scope.dataObj.targetList.length, // length of data
            getData: function( params ) {
                //return $scope.dataObj.targetList.slice((params.page() - 1) * params.count(), params.page() * params.count());
                var filteredData = $filter('filter')( $scope.dataObj.targetList, $scope.dataObj.tableGlobalSearch );
                var targetListParams = params.sorting() ? $filter( 'orderBy' )( filteredData, params.orderBy() ) : filteredData;
                targetListParams = params.filter ? $filter( 'filter' )( targetListParams, params.filter() ) : targetListParams;
                params.total(filteredData.length);
                return targetListParams.slice( (params.page() - 1) * params.count(), params.page() * params.count() );
            }
        });
        self.initNgTblGlobalSearch( $scope.dataObj.targetListTblParams );
	}
	$scope.getData = function() {
		console.log( 'Filters ',$scope.filters );	
		if( window.oppRec.recordId != '' )	{
			$scope.dataObj.showLoader = true;
			var options = {
	            url : 'TargetListController.getContactRecords',
	            params : [ JSON.stringify( window.oppRec ), window.setOppLineItem.slice(1, -1), JSON.stringify( $scope.filters ) ],
	        };
	        remotingFactory.invokeRemoteAction(options).then(
	            // success function
	            function( result ) {
	                console.log( 'getContactRecords result: ', result );
	                if( result.isSuccess ) {
	                	$scope.dataObj.targetList = result.recordList;
	                	self.initTargetListTbl();
	                	$scope.dataObj.checkAll = false;
	                	$scope.checkIfAllChecked();
	                	$scope.dataObj.showLoader = false;
	                } else {
	                	$scope.dataObj.targetList = [];
	                	self.initTargetListTbl();
	                	$scope.dataObj.showLoader = false;
	                	$scope.dataObj.showPopupMsg = true;
	                	$scope.dataObj.popupMessage = result.message;
	                }                            
	            },
	            // error function
	            function(error){                    
                    $scope.dataObj.targetList = [];
	            	$scope.dataObj.showLoader = false;
	            	$scope.dataObj.showPopupMsg = true;
	                $scope.dataObj.popupMessage = error;   
	            }
	        );
    	} else {
    		$scope.dataObj.showPopupMsg = true;
	        $scope.dataObj.popupMessage = "To create target list opportuniti's stage should be Creating Target List";
    	}
	}
	$scope.checkAllTargetList = function( isChecked ) {		
		angular.forEach( $scope.dataObj.targetList, function( item ){ 
			if( !item.isTargetListPresent ) { //do not touch to already created target list records
				if( !angular.isUndefined( item.isChecked )  ) {				
					if( isChecked ) {
						item.isChecked = true;
					} else {
						item.isChecked = false;
					}
				} else {
					if( isChecked ) {
						item[ 'isChecked' ] = true;
					} else {
						item[ 'isChecked' ] = false;
					}
				}
			}
		});
	}
	$scope.checkIfAllChecked = function( checkAllModel ) {
		if( $filter('filter')( $scope.dataObj.targetList, { 'isChecked' : false }).length == 0 ) {
			$scope.dataObj.checkAll = true;	
		} else {
			if( $scope.dataObj.checkAll == true ) {
				$scope.dataObj.checkAll = false;								
			}
		}
	}
	$scope.changePerPageCount = function( pageCount ) {
		if( pageCount == 'All' ) {
			$scope.dataObj.targetListTblParams.count( $scope.dataObj.targetList.length );
		} else {
			$scope.dataObj.targetListTblParams.count( pageCount );
		}		
	}
	$scope.nextPage = function( pageNo ) {
		alert("test");
		$scope.dataObj.targetListTblParams.page( pageNo );
	}
	$scope.createTargetList = function() {		
		//var checkedRecords = $filter('filter')( $scope.dataObj.targetList, { 'isChecked' : true });
		var checkedRecords = $filter('filter')( $scope.dataObj.targetList, { 'isChecked' : true, 'isTargetListPresent' : false });
		if( checkedRecords.length > 0 ) {
			$scope.dataObj.showLoader = true;
			var options = {
	            url : 'TargetListController.createTargetList',
	            params : [ JSON.stringify( window.oppRec ),  checkedRecords  ],
	        };
	        remotingFactory.invokeRemoteAction(options).then(
	            // success function
	            function( result ) {
	                console.log( 'createTargetList result: ', result );                
	            	//$scope.dataObj.showLoader = false;
	            	$scope.getData(); //fetch new data to refreash page
	            	$scope.dataObj.showPopupMsg = true;
	            	$scope.dataObj.popupMessage = result.message;
	            },
	            // error function
	            function(error){
	            	$scope.dataObj.showLoader = false;
	            	$scope.dataObj.showPopupMsg = true;
	                $scope.dataObj.popupMessage = error;   
	            }
	        );
    	} else {
    		$scope.dataObj.showPopupMsg = true;
            $scope.dataObj.popupMessage = "Please select any one record";
    	}
	}
} );

/*function consultantFactory(){
    var ConsultantObj = {};
    ConsultantObj.hideWizardPopup = true;
    
    ConsultantObj.displayWizard = function(){
        ConsultantObj.hideWizardPopup = false;
    }
    
    return ConsultantObj;
}

app.factory('consultantFactory',consultantFactory);*/

function numericType(){
    return {
        restrict:'A',
        require:'ngModel',
        scope:{
          showError:'&'  
        },
        link:function(scope,elem,attr,ngModel){
            
            function inputValue(val){
                if(val){
                    var input = val.replace(/[^0-9]/g,'');
                    if(input!==val){
                        ngModel.$setViewValue(input);
                        ngModel.$render();
                    }
                    
                    return input;
                }
                return "";
            }
            ngModel.$parsers.push( inputValue );
        }
    };
}

targetListApp.directive('numericType',numericType);

function numericDot(){
    return {
        restrict:'A',
        require:'ngModel',
        scope:{
          showError:'&'  
        },
        link:function(scope,elem,attr,ngModelCtrl){
             function inputValue(val) {
               if ( val ) {
                   var digits = val.replace( /[^0-9.]/g, '' );
                   var digitArr = digits.split('.');
                   if( digitArr.length == 2 ) {
                       digits = digitArr[ 0 ] + '.' + digitArr[1].substring( 0, 2 );
                   }
                   if ( digitArr.length > 2 ) {
                       digits = digits.substring( 0, digits.length - 1 );
                   }
                   if ( digits !== val ) {
                       ngModelCtrl.$setViewValue( digits );
                       ngModelCtrl.$render();
                   }
                   return parseFloat( digits );
               }
               return "";
           }
           ngModelCtrl.$parsers.push( inputValue );
            
        }
    };
}

targetListApp.directive('numericDot',numericDot);

targetListApp.controller('consultantController',function($scope,remotingFactory,$filter){
    $scope.accountDetails = {};
    $scope.contactDetails = {};
    $scope.errorMessage={};
    $scope.oppoturnityDetails={};
    $scope.hideWizard={hideWizardPopup : true,hideAccountConfirmBox:true,hideContactConfirmBox:true,hideTargetConfirmBox:true,hideErrorBox:true};
    $scope.accountSubmitted = false;
    $scope.contactSubmitted = false;
    $scope.currentStep = 1;
    $scope.progressBarWidth = '0%';
    $scope.showError = false;
    var accountRecord = {},contactRecord={};
    var popupcontent = document.getElementById('popupAlertMsg');
    $scope.steps=[
      {
        label:'New Account Record',
        step:1
    },
    {
        label:'New Contact Record',
        step:2
    },{
        label:'New Target List Record',
        step:3
    }];
    
    $scope.displayWizard = function(){
        if(!window.oppRec.recordId){
            $scope.$parent.dataObj.showPopupMsg = true;
            $scope.$parent.showError = true;
            $scope.$parent.dataObj.popupMessage = 'Opportunity is missing';
            
            
        }else{
            $scope.hideWizard.hideWizardPopup =false;
            $scope.$parent.dataObj.showPopupMsg = false;
        }
        
    }
    
    $scope.closeWizard = function(){
        $scope.hideWizard.hideWizardPopup=true;
        $scope.currentStep=1;
        $scope.accountDetails = {};
    	$scope.contactDetails = {};
        $scope.oppoturnityDetails = {};
        $scope.vm.accountForm.$setPristine();
        $scope.vm.contactForm.$setPristine();
        $scope.progressBarWidth = '0%';
        $scope.hideWizard.hideAccountConfirmBox =true;
        $scope.hideWizard.hideContactConfirmBox =true;
        $scope.hideWizard.hideTargetConfirmBox=true;
        $scope.hideWizard.hideErrorBox = true;
        $scope.$parent.dataObj.showPopupMsg = false;
        
        //$scope.$parent.dataObj.popupMessage = 'Opportunity is missing';
    }
    
   $scope.getRecruitingSource = function(){
        	var options = {
	            url : 'TargetListController.getPickListValuesIntoList',
	            params : []
	        };
            
            remotingFactory.invokeRemoteAction(options).then(
                // success function
                function( result ){
                    console.log(result);
                    if(!$scope.contactDetails.recrutingSourceList){
                        $scope.contactDetails.recrutingSourceList=[];
                    }
                    
                    $scope.contactDetails.recrutingSourceList = result;
                    Array.prototype.insert = function ( index, item ) {
    					this.splice( index, 0, item );
					};
                    $scope.contactDetails.recrutingSourceList.insert(0, 'None');
                    $scope.contactDetails.recruitingSource =  $scope.contactDetails.recrutingSourceList[0];
                },
                function( error ){
                    console.log(error);
                }
            );
    }
    
   function showConfirmModal(){
       if($scope.currentStep==1 && $scope.vm.accountForm.$valid){
           $scope.hideWizard.hideAccountConfirmBox =false;
       }else if($scope.currentStep==2 && $scope.vm.contactForm.$valid){
           $scope.hideWizard.hideContactConfirmBox =false;
       }else{
           $scope.hideWizard.hideAccountConfirmBox =true;
           $scope.hideWizard.hideContactConfirmBox =true;
           $scope.hideWizard.hideErrorBox = true;
       }
       $scope.$parent.showError = false;
   }
   
    $scope.saveAccountDetails = function(){
        	var accountObj = {
                firstName:$scope.accountDetails.firstName,
                lastName:$scope.accountDetails.lastName
            };
            var options = {
	            url : 'TargetListController.createAccountRecord',
	            params : [ JSON.stringify( accountObj )  ]
	        };
            
            remotingFactory.invokeRemoteAction(options).then(
                // success function
                function( result ){
                    console.log(result);
                    //getRecruitingSource();
                    if(result.isSuccess){
                        activateStep(1);
                        accountRecord = result.record;
                        //var recordNameArray = result.record.Name.split(' ');
                        $scope.contactDetails.firstName = $scope.accountDetails.firstName;
                        $scope.contactDetails.lastName = $scope.accountDetails.lastName;
                        $scope.hideWizard.hideAccountConfirmBox =true;
                        $scope.$parent.dataObj.showPopupMsg = false;
                        $scope.$parent.showError = false;
                        $scope.getRecruitingSource();
                    }else{
                        $scope.$parent.dataObj.showPopupMsg = true;
            			$scope.$parent.dataObj.popupMessage = result.message;
                        $scope.hideWizard.hideErrorBox = false;
                        $scope.$parent.showError = true;
                    }
                    
                },
                function( error ){
                    
                    console.log(error);
                }
            );
    }
    
    $scope.saveContactDetails = function(){
        if(!$scope.contactDetails.currentlyEmployed){
            $scope.contactDetails.currentlyEmployed = false;
        }
        
        var options = {
	            url : 'TargetListController.createContactRecord',
	            params : [ JSON.stringify( $scope.contactDetails ), accountRecord ]
	        };
            
            remotingFactory.invokeRemoteAction(options).then(
                // success function
                function( result ){
                    if(result.isSuccess){
                        console.log(result);
                        contactRecord = result.record;
                        $scope.oppoturnityDetails.Name = window.oppRec.Name;
                        $scope.oppoturnityDetails.ContactName = contactRecord.FirstName +' '+contactRecord.LastName;
                        //getOpportunityDetails(contactRecord);
                        $scope.hideWizard.hideContactConfirmBox =true;
                        $scope.hideWizard.hideErrorBox = true;
                        $scope.$parent.dataObj.showPopupMsg = false;
                        $scope.$parent.showError = false;
                        activateStep(1);
                    }else{
                        $scope.$parent.dataObj.showPopupMsg = true;
            			$scope.$parent.dataObj.popupMessage = result.message;
                        $scope.hideWizard.hideErrorBox = false;
                        $scope.$parent.showError = true;
                    }
                    
                },
                function( error ){
                    console.log(error);
                    
                }
            );
    }
    
    $scope.nextStep = function(type){
        
        
        if($scope.currentStep==1 && !$scope.vm.accountForm.$valid){
            $scope.accountSubmitted = true;
            return false;
        }else if($scope.currentStep==2 && !$scope.vm.contactForm.$valid){
            $scope.contactSubmitted = true;
            return false;
        }else{
            $scope.accountSubmitted = false;
    		$scope.contactSubmitted = false;
        }
        
        
        showConfirmModal();
        
    }
    
    $scope.createTargetList = function(){
        getOpportunityDetails(contactRecord);
    }
    
    function getOpportunityDetails(contactRec){
        	var options = {
	            url : 'TargetListController.createTargetListRecord',
	            params : [ contactRec.Id, window.oppRec.recordId ]
	        };
            
            remotingFactory.invokeRemoteAction(options).then(
                // success function
                function( result ){
                    if(result.isSuccess){
                        console.log(result);
                        //activateStep(1);
                        //var recordNameArray = result.record.Name.split(' ');
                        
                        $scope.hideWizard.hideTargetConfirmBox = false;
                        $scope.hideWizard.hideErrorBox = true;
                        $scope.$parent.dataObj.showPopupMsg = false;
                        $scope.$parent.showError = false;
                        //$scope.closeWizard();
                        //activateStep(1);
                    }else{
                        $scope.$parent.dataObj.showPopupMsg = true;
            			$scope.$parent.dataObj.popupMessage = result.message;
                        $scope.hideWizard.hideErrorBox = false;
                        $scope.$parent.showError = true;
                    }
                    
                    
                },
                function( error ){
                    console.log(error);
                }
            );
    }
    
    function activateStep(type){
            if(type==1){
                if($scope.currentStep<3){
                    
                    $scope.currentStep += 1;
                    if($scope.currentStep==1){
                        $scope.progressBarWidth = '0%';
                    }else if($scope.currentStep==2){
                        $scope.progressBarWidth = '50%';
                    }else if($scope.currentStep==3){
                        $scope.progressBarWidth = '100%';
                    }
                    
                }
                
            }else{
                if($scope.currentStep>0){
                    $scope.currentStep -= 1;
                }
            }
    }
    
    
});