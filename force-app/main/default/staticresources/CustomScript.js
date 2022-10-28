var attchmentist = new Array();

var maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
var maxFileSize = 4350000; //After Base64 Encoding, this is the max file size
var chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
var attachment = ['', ''];
var attachmentName;
var fileSize;
var attfileSize = [0, 0];
var positionIndex = [0, 0];
var doneUploading = [false, false];

var jsonOptions = new Array();
var BrandsControl = new Array();

var attType;
var overWriteFlag = false;

var resumeUploaded;

var resumeULhtml;
var profileULhtml;

var currentStep;
var saveFlag = false;
var lastChildFlag = false;
var imageURL = '';
var stepValid = false;

/*
 *Purpose : Show hide steps after clicking on 'Previous' button
 */
function handlePreviousButton() {
    console.log('handlePreviousButton()');
    $('.allsteps').hide();
    currentStep = $('.active').prev().find('a').attr('href');
    console.log('currentStep in handlePreviousButton',currentStep);
    $('.active').prev().addClass('active');
    console.log( 'active prev',$('.active').prev() );
    $('.active').next().removeClass('active');
    console.log( 'active next',$('.active').next() );
    $(currentStep).show();
    
    if ($('#step-bar li:first-child a').text() === $('.active a').text()) {
        $('#prevBtnId').attr('Disabled', 'Disabled');
    } else {
        $('#saveBtnId').attr('value', 'SAVE AND NEXT');
    }
}

function checkChange( elm, type ){
    console.log( "isChecked", elm.checked );
    var isChecked = elm.checked;
    if( type=='cityCheckBox' ){ 
        if( isChecked ) {
            $( ".city-fields" ).find(".required-mark").show();
        } else {
            $( ".city-fields" ).find(".required-mark, .errorClass").hide();
        }
        /*var errorElement = $('.errorClass');
        $( errorElement[1] ).hide();
        $( errorElement[0] ).hide();*/
        
    }else if( type=='delphiCheckBox' ){
        if( isChecked ) {
            $( ".delphi-fields" ).find(".required-mark").show();
        } else {
            $( ".delphi-fields" ).find(".required-mark, .errorClass").hide();
        }
    }
}

/*
 *Purpose : Validate contact related data and save data after clicking on save Button
 */
function handleSaveButton() {
    saveFlag = true;
    invalid = false;
    
    // Getting current step
    currentStep = $('#step-bar').find('li.active a').attr('href');
    lastChildFlag = false;
    
    // Do form validations
    validationCheker(currentStep, lastChildFlag);
    
    console.log('invalid==>',invalid);
    console.log( 'checkBox val: ', $('.cityCheckBox').length, $('.cityCheckBox').prop("checked") );
    var cityCheckBoxValue = $('.cityCheckBox').prop("checked");
    var delphiCheckBoxValue = $('.delphiCheckBox').prop("checked");
    console.log("currentStep::", currentStep);
    
    // If current step is '#first-step' show hide required fields
    if( currentStep=="#first-step" ){
        console.log('In first-step==>',currentStep);
        if( $(".cityCheckBox").prop("checked") ) {
            $( ".city-fields" ).find(".required-mark").show();
        } else {
            $( ".city-fields" ).find(".required-mark").hide();
        }
        
        if( $(".delphiCheckBox").prop("checked") ) {
            $( ".delphi-fields" ).find(".required-mark").show();
        } else {
            $( ".delphi-fields" ).find(".required-mark").hide();
        }
    }
    
    // If current step is '#second-step' show hide required fields
    if(currentStep=="#second-step" && cityCheckBoxValue){
        console.log('In second-step==>',currentStep);
        var cityEid = $('.cityEid'),cityDateCertified = $('.cityDateCertified'),invalid=false;
        var errorElement = $('.errorClass');
        console.log( "errorElement", errorElement );
        var cityEidValue = cityEid[0].value ? cityEid[0].value : '';
        var cityDateCertifiedValue = cityDateCertified[0].value ? cityDateCertified[0].value : '';
        
        if(cityEidValue=='' && cityDateCertifiedValue==''){
            $( errorElement[0] ).show();
            $( errorElement[1] ).show();
            invalid = true;
        }else if(cityEidValue=='' && cityDateCertifiedValue!=''){
            $( errorElement[0] ).show();
            $( errorElement[1] ).hide();
            invalid = true;
        }else if(cityEidValue!='' && cityDateCertifiedValue==''){
            $( errorElement[1] ).show();
            $( errorElement[0] ).hide();
            invalid = true;
        }else{
            $( errorElement[1] ).hide();
            $( errorElement[0] ).hide();
        }
    }
    
    if(currentStep=="#second-step" && delphiCheckBoxValue){
        var selectBoxValue = $('.delphiSelect')[0].value;
        var delphiErrorClass = $('.delphiErrorClass');
        if(!selectBoxValue || selectBoxValue=='' || selectBoxValue=='None'){
            $( delphiErrorClass[0] ).show();
            invalid = true;
        }else{
            
                $( delphiErrorClass[0] ).hide();
            
        }
    }else{
        if($('.delphiErrorClass' ) && $('.delphiErrorClass' )[0]){
            $($('.delphiErrorClass' )[0]).hide();
        }
    }
    console.log( "invalid: ", invalid, 'saveFlag: ', saveFlag );
    
    // IF form data is not valide show form required field messages.
    if(invalid || !saveFlag){
        $(window).scrollTop($('#skillTechExp').position().top-20); 
        return false;
    }
    
    // Save Contact and its related data
    saveData();  
    
    // If currentStep is not '#fift-step' then only activate or deactivate and show/ hide steps
    if(currentStep != '#fift-step'){
        // Getting next step of current activated step
        var nextStep = $('.active').next().find('a').attr('href');
        // Removed 'Disabled' propery of 'Previous' button except first step previous button.
        $('#prevBtnId').removeAttr('Disabled');
        // Hide all other steps excepts current activated step
        $('.allsteps').hide();
        console.log( 'allsteps len',$('.allsteps').length, 'nextStep:', nextStep );
        // deactivate current step
        $( '#step-bar li' ).removeClass('active');
       
        if( nextStep ) {
            console.log( "innn", $( "a[href="+nextStep+"]" ).parents('li') );
            // Activate next step of current step
            $( "a[href="+nextStep+"]" ).parents('li').addClass('active');
            // show next step
            $(nextStep).show();
        }
        currentStep = $('.active').find('a').attr('href');
        console.log('CurrentStep ::::::::',currentStep);
        console.log( 'currentStep len',$(currentStep).length );  
        
        if ($('#step-bar li:last-child').find('a').text() === $('.active').find('a').text()) {
            // If cuurent step is last step then change 'SAVE AND NEXT' button value to Save.
            $('#saveBtnId').attr('value', 'SAVE');
        }
    }
}

/*
 *Purpose : Validate contact form data 
 */
function validationCheker(currentNode, lastChldFlg) { //#first-step, false
    console.log('In validationCheker()');
    console.log('currentNode==>'+currentNode);
    
    if($('[href=' + currentNode + ']').text() === $('#step-bar li:last-child').prev().find('a').text() || lastChldFlg){
     var blankValCounter;
     lastChldFlg = true;
     $(currentNode + ' fieldset').each(function(){
         blankValCounter = 0;
         $(this).find('.eitherClass').each(function(){
             if(!($(this).val().trim()))
                blankValCounter++;
         });
         console.log('blankValCounter==>',blankValCounter);
         if(blankValCounter === 2) {
          $('.allsteps').hide();
          $(currentNode).show();
          $('#prevBtnId').removeAttr('Disabled');
          $('#Multi-step-form #step-bar li').removeClass('active');
          $('[href=' + currentNode + ']').parent().parent().addClass('active');
          $('#saveBtnId').attr('value', 'SAVE AND NEXT');
          if($(this).find('.Bcompact-btn').prev().is(':visible')){
           $(this).find('.Bcompact-btn').trigger('click');    
          }             
          $(this).find('#BerrorDivId').text('Please Fill Either Field').show(500).delay(1000).hide(500);
          saveFlag = false;
             
          return false;
         } else {
          $(this).find('#BerrorDivId').text('');
         }
     });      
    }
    /*if (isNewUser) {
        $(currentStep + ' .upload-section').children().each(function() {
            //console.log($(this).find(':first').css('border-color').toString());
            if ($(this).find(':first').css('border-color').toString() === "rgb(255, 0, 0)") {
                $('.allsteps').hide();
                $(currentNode).show();
                $('#prevBtnId').removeAttr('Disabled');
                $('#Multi-step-form #step-bar li').removeClass('active');
                $('[href=' + currentNode + ']').parent().parent().addClass('active');
                $('#saveBtnId').attr('value', 'SAVE AND NEXT');
                $(window).scrollTop(180);
                var errorText;
                if($(this).find(':first').attr('class').indexOf('resume') > -1){
                    errorText = 'Resume';  
                } else {
                    errorText = 'Profile Image';
                }
                $('#errorDivId').html('Please Fill Required Field : ' + errorText).show(500).delay(1000).hide(500);
                $(this).find('button').focus();
                currentStep = $('.active').find('a').attr('href');
                $('.active').removeClass('done');
                saveFlag = false;
                return false;
            }
        });
    }*/
    
    $(currentNode + ' .firstImp').each(function() {
        if ($(this).css('border-top-color').toString() === "rgb(255, 0, 0)") {
            $('.allsteps').hide();
            $(currentNode).show();
            $('#prevBtnId').removeAttr('Disabled');
            $('#Multi-step-form #step-bar li').removeClass('active');
            $('[href=' + currentNode + ']').parent().parent().addClass('active');
            //$('.active').removeClass('done');
            if (lastChldFlg) {
                var requiredObj = $(this);
                $(currentNode + ' fieldset').each(function(){
                    if($(this).has(requiredObj).length){
                        if($(this).find('.JEcompact-btn').parent().prev().is(':visible')) {
                            $(this).find('.JEcompact-btn').trigger('click');
                        }
                        $(this).find('#JEerrorDivId').text('Please Fill Required Field : '+$(requiredObj).parent().find('label').text().split(':')[0]).show(500).delay(1000).hide(500);
                        
                        if($(this).find('.Bcompact-btn').parent().prev().is(':visible')) {
                            $(this).find('.Bcompact-btn').trigger('click');
                        }
                        $(this).find('#BerrorDivId').text('Please Fill Required Field : '+$(requiredObj).parent().find('label').text().split(':')[0]).show(500).delay(1000).hide(500);
                        
                        return false;
                    } else {
                     lastChldFlg = false;
                    }
                });
            } else {
             $('#saveBtnId').attr('value', 'SAVE AND NEXT');
                $('#errorDivId').html('Please Fill Required Field : ' + $(this).parent().find('label').text().split(':')[0]).show(500).delay(1000).hide(500);
                console.log('required field::::',$(this).parent().find('label').text().split(':')[0]);
            }
            $(window).scrollTop(180);
            $(this).focus();            
            if ($('#step-bar li:first-child').find('a').text() === $('.active').find('a').text()) {
                $('#prevBtnId').attr('Disabled', 'Disabled');
            }            
            saveFlag = false;
            return false;
        }
    });
}

/*
 *@Purpose : Save Contact related data
 */
function saveData() {
    //console.log('Save Called');
    console.log('insertedAttachmentList in saveData()::',insertedAttachmentList);
    
    // Show Loader
    $('.background-block').show();
    
    // If Attchments exists then upload them.
    if (attchmentist.length > 0) {
        console.log('attchmentist::',attchmentist);
        isclosePage = attchmentist.length == 2 ? true: false;
        var attCounter = 0;
        
        attchmentist.forEach(function(att) {
            // Set attachment related attributes
            attachment[attCounter] = att.attachment;
            attachmentName = att.attachmentName;
            attfileSize[attCounter] = att.fileSize;
            positionIndex[attCounter] = 0;
            doneUploading[attCounter] = false;
            
            console.log('attchmentist :: attachmentName ::',att.attachmentName);
            
            if (attachment[attCounter].length < maxStringSize) {
                
                // If attachments are already inserted then UPSERT them 
                if(insertedAttachmentList.length > 0){
                    
                    // Check each inserted attachment
                    insertedAttachmentList.forEach(function(insertedAttachment){
                        // If attachment is changed after clicking pervious button upsert it.
                        if( insertedAttachment.type == att.type && insertedAttachment.name != att.attachmentName){
                            console.log('Uploading attch new :');
                            // Show loader
                            $('.background-block').show();
                            uploadAttachment(insertedAttachment.attachment, insertedAttachment.type, attCounter, true); 
                        }else{
                            // Hide loader
                            $('.background-block').hide();
                        }
                    });
                }else{                    
                    // IF attachments not inserted previously.
                    console.log('IF attachments not inserted previously');
                    uploadAttachment(null, att.type, attCounter, false);  
                }
            } else {
                alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + attfileSize[attCounter] + ". Please select other file..!!");
                $('.background-block').fadeOut(200);
            }
            attCounter++;
        });
    } else {
        //console.log('complateInsert Direct Call');
        var Languages = '';
        if (($('#selectLanguagesId').val())) {
            Languages = ($('#selectLanguagesId').val()).join().split(',').join(';');
        }
    }   
    console.log('final current step==>',currentStep);
    complateInsert(Languages, '',currentStep);
}

//Prepare Attachment logic
function readURL(input) {
    $('.background-block').fadeIn(200);
    //console.log("Out");
    if(window.FileReader) {
        if (input.files && input.files[0]) {
            //console.log("In");
            attachmentName = input.files[0].name;
            console.log('Input file ::',input.files[0]);
            var reader = new FileReader();
            reader.onload = function(e) {
                fileSize = getAttachmentFileSize(input);
                var Data = '';
                if(window.navigator.userAgent.indexOf('.NET') > -1) {
                    console.log( "in if navigator" );
                    Data = e.target.result;
                } else {
                    console.log( "in else navigator" );
                    Data = window.btoa(e.target.result);
                }
                console.log("Total Attachment Length: " + Data.length);
                if( Data.length > maxStringSize ) {
                    console.log( "string length exceeds" );
                }
                //console.log('fileSize : ' + fileSize);
                if (fileSize < 5120) {
                    overWriteFlag = false;
                    var r = confirm("Are You Sure To Add File?");
                    if (r == true) {
                        if (!resumeUploaded) {
                            $('.resume-section ul li').html(attachmentName);
                            resumeUploaded = false;
                            attType = 'resume';
                            
                            if (attchmentist.length > 0) {
                                attchmentist.forEach(function(att) {
                                    if (!overWriteFlag) {
                                        if (att.type === attType) {
                                            overWriteFlag = true;
                                        } else {
                                            overWriteFlag = false;
                                        }
                                    }
                                });
                            } else {
                                overWriteFlag = false;
                            }
                        } else {
                            $('.picture-section ul li').html(attachmentName);
                            attType = 'profile';
                            if (attchmentist.length > 0) {
                                attchmentist.forEach(function(att) {
                                    if (!overWriteFlag) {
                                        if (att.type === attType) {
                                            overWriteFlag = true;
                                        } else {
                                            overWriteFlag = false;
                                        }
                                    }
                                });
                            } else {
                                overWriteFlag = false;
                            }
                        }
                        //console.log('attachmentName : ' + attachmentName);
                        if (overWriteFlag) {
                            attchmentist.forEach(function(att) {
                                if (att.type === attType) {
                                    
                                    att.attachment = Data,
                                    att.attachmentName = attachmentName,
                                    att.fileSize = Data.length
                                    console.log('Data:::',Data);
                                }
                            });
                        } else {
                            attchmentist.push({
                                attachment: Data,
                                attachmentName: attachmentName,
                                fileSize: Data.length,
                                type: attType
                            });
                        }
                        //console.log('attchmentist :: size :' + attchmentist.length);
                        $(input).parent().css('border', '1px solid lightgrey');
                        $('#uploadMsgDivId').html('<span style="color:green;">Your Attachment Uploaded Successfully..!!</span>').show(500).delay(5000).hide(500);
                    } else {
                        alert('Upload file Aborted..!!');
                        $('.background-block').fadeOut(200);
                    }
                } else {
                    alert('File Size more than 5mb..!!');
                    $('.background-block').fadeOut(200);
                }
            };
            if(window.navigator.userAgent.indexOf('.NET') > -1) {
                reader.readAsDataURL(input.files[0]);
            } else {
                reader.readAsBinaryString(input.files[0]);                        
            }           
        }
    } else {
        $('#uploadMsgDivId').html('<span style="color:red;">This Browser Version Does\'t Support This uploading Facility..!! Please Try With Different Browser..!</span>').show(500).delay(5000).show(500);
        //$('#errorDivId').html('This Browser Version Does\'t Support This Facility..!! Please Try With Different Browser..!').show(500).delay(1500).hide(500);
    }
    $('.background-block').fadeOut(200);
}

function removeFile(file) {
    if (file == 'resume') {
        $('.resume-section ul li').html(resumeULhtml);
        if (attchmentist.length > 0) {
            attchmentist = $.grep(attchmentist, function(e) {
                return e.type != 'resume';
            });
            //if (isNewUser)
                //$('.resumeInId').parent().css('border', '1px solid red');
        }
    } else {
        $('.picture-section ul li').html(profileULhtml);
        if (attchmentist.length > 0) {
            attchmentist = $.grep(attchmentist, function(e) {
                return e.type != 'profile';
            });
            //if (isNewUser)
                //$('.profileInId').parent().css('border', '1px solid red');
        }
    }
}

function getAttachmentFileSize(attachmentFile) {
    var fileSize = 0;
    // for IE < 9
    if (window.ActiveXObject) {
        var AxFSObj = new ActiveXObject("Scripting.FileSystemObject");
        var AxFSObjFile = AxFSObj.getFile(attachmentFile);
        fileSize = AxFSObjFile.size * 8; //in KB
    }
    // for other browsers
    else {
        fileSize = attachmentFile.files[0].size / 1024; // in kB
    }
    return fileSize;
}

function ArrayBufferToString(buffer) {
    return BinaryToString(String.fromCharCode.apply(null, Array.prototype.slice.apply(new Uint8Array(buffer))));
}

function StringToArrayBuffer(string) {
    return StringToUint8Array(string).buffer;
}

function BinaryToString(binary) {
    var error;

    try {
        return decodeURIComponent(escape(binary));
    } catch (_error) {
        error = _error;
        if (error instanceof URIError) {
            return binary;
        } else {
            throw error;
        }
    }
}

function StringToBinary(string) {
    var chars, code, i, isUCS2, len, _i;

    len = string.length;
    chars = [];
    isUCS2 = false;
    for (i = _i = 0; 0 <= len ? _i < len : _i > len; i = 0 <= len ? ++_i : --_i) {
        code = String.prototype.charCodeAt.call(string, i);
        if (code > 255) {
            isUCS2 = true;
            chars = null;
            break;
        } else {
            chars.push(code);
        }
    }
    if (isUCS2 === true) {
        return unescape(encodeURIComponent(string));
    } else {
        return String.fromCharCode.apply(null, Array.prototype.slice.apply(chars));
    }
}

function StringToUint8Array(string) {
    var binary, binLen, buffer, chars, i, _i;
    binary = StringToBinary(string);
    binLen = binary.length;
    buffer = new ArrayBuffer(binLen);
    chars  = new Uint8Array(buffer);
    for (i = _i = 0; 0 <= binLen ? _i < binLen : _i > binLen; i = 0 <= binLen ? ++_i : --_i) {
        chars[i] = String.prototype.charCodeAt.call(binary, i);
    }
    return chars;
}