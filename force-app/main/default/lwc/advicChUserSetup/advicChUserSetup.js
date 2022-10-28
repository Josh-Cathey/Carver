/**
 * Created by Holden.Parker on 1/17/22.
 */

import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchInitData from '@salesforce/apex/AdVic_CH_UserSetup.fetchInitData';
import saveAllData from '@salesforce/apex/AdVic_CH_UserSetup.saveAllData';
import wireDelphiStandardOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireDelphiStandardOptions';
import wireLanguagesOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireLanguagesOptions';
import wireBrandsOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireBrandsOptions';
import wireFamilyOfBrandsOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireFamilyOfBrandsOptions';
import wirePropertyStateOptions from '@salesforce/apex/AdVic_CH_UserSetup.wirePropertyStateOptions';
import wireEmploymentMonthOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireEmploymentMonthOptions';
import wireEmploymentYearOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireEmploymentYearOptions';
import wireStillWorkingThereOptions from '@salesforce/apex/AdVic_CH_UserSetup.wireStillWorkingThereOptions';

export default class AdvicChUserSetup extends NavigationMixin(LightningElement) {
    steps = [
        { label: 'Your General Background', value: 'step-1' },
        { label: 'Profile Picture & Resume', value: 'step-2' },
        { label: 'Hotel Brands', value: 'step-3' },
        { label: 'Recent Employment History Review', value: 'step-4' },
        { label: 'Additional Information', value: 'step-5' },
    ];

    @track _attachments = [];
    @track _brands = [];
    @track _jobExperience = [];
    @track _contact = {};
    recordId;
    selectedLanguages;
    _isLoading;
    _resumeMessage;
    _profilePicMessage;

    _currentStep = 'step-1';
    get currentStep() {
        return this._currentStep
    }
    set currentStep(value) {
        this._currentStep = value;
        this.loadStepData();
    }

    get isStep1() {
        return (this.currentStep === this.steps[0].value);
    }

    get isStep2() {
        return (this.currentStep === this.steps[1].value);
    }

    get isStep3() {
        return (this.currentStep === this.steps[2].value);
    }

    get isStep4() {
        return (this.currentStep === this.steps[3].value);
    }

    get isStep5() {
        return (this.currentStep === this.steps[4].value);
    }

    get saveButtonLabel() {
        if (this.isStep5) return 'Save';
        return 'Save and Next';
    }

    get isDelphiDisabled() {
        return (!this._contact?.Delphi__c);
    }

    get resumeFormats() {
        return ['.pdf', '.doc', '.docx'];
    }

    get profilePicFormats() {
        return [
            '.jpg', '.jpeg', '.jpe', '.jif', '.jfif', '.jfi', '.png', '.gif', '.webp', '.tiff', '.tif', '.psd', '.raw',
            '.arw', '.cr2', '.nrw', '.k25','.bmp', '.dib', '.heif', '.heic', '.ind', '.indd', '.indt', '.jp2', '.j2k',
            '.jpf', '.jpx', '.jpm', '.mj2', '.svg', '.svgz', '.ai', '.eps', '.pdf'
        ];
    }

    get galaxyLabel() {
        return 'Galaxy/\u200BLightSpeed';
    }

    @wire(wireDelphiStandardOptions)
    delphiStandardOptions;

    @wire(wireLanguagesOptions)
    languageOptions;

    @wire(wireBrandsOptions)
    brandsOptions;

    @wire(wireFamilyOfBrandsOptions)
    familyOfBrandsOptions;

    @wire(wirePropertyStateOptions)
    propertyStateOptions;

    @wire(wireEmploymentMonthOptions)
    employmentMonthOptions;

    @wire(wireEmploymentYearOptions)
    employmentYearOptions;

    @wire(wireStillWorkingThereOptions)
    stillWorkingThereOptions;

    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        this._isLoading = true;
        const response = await fetchInitData();
        if (response.error) {
            this.showNotification('error', response.error);
        } else if (response.data) {
            const data = response.data;
            if (data.contact) {
                this._contact = data.contact;
                this.recordId = data.contact.Id;
            }
            if (data.brands) this._brands = data.brands.map((brand, i) => {
                brand.key = (i + 1);
                return brand;
            });
            if (data.jobExperience) this._jobExperience = data.jobExperience.map((experience, i) => {
                experience.key = (i + 1);
                return experience;
            });
        }
        this._isLoading = false;
    }

    handleProgressClick(event) {
        const step = event.target.dataset.step;
        if (!step) {
            this.currentStep = this.currentStep;
        } else {
            this.currentStep = step;
        }
    }

    handleStep1FormChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        this._contact[field] = value;
    }

    handleStep2FormChange(event) {
        const field = event.target.name;
        const isMultiSelect = (field === 'Languages__c');
        const value = (isMultiSelect ? event.detail.value : event.target.value);
        this._contact[field] = (isMultiSelect ? value.join(';') : event.target.value);
        if (isMultiSelect) this.selectedLanguages = value;
    }

    handleStep2CheckboxChange(event) {
        const field = event.target.name;
        const isChecked = event.target.checked;
        this._contact[field] = isChecked;
        if (field === 'Delphi__c' && !isChecked) {
            this._contact.Delphi_Standard_or_FDC__c = '';
        }
    }

    handleStep3FormChange(event) {
        const brandIndex = event.target.dataset.index;
        const field = event.target.name;
        const isMultiSelect = (field === 'Brands__c')
        const isControllingField = (field === 'Family_of_Brands__c')
        const value = (isMultiSelect ? event.detail.value : event.target.value);
        const brand = this._brands[brandIndex];
        brand[field] = (isMultiSelect) ? value.join(';') : value;
        if (isMultiSelect) brand.selectedOptions = value;
        if (isControllingField) brand.brandsOptions = this.brandsOptions.data[value];
        this._brands[brandIndex] = brand;
    }

    handleBrandExpand(event) {
        const brandIndex = event.target.dataset.index;
        const brand = this._brands[brandIndex];
        brand.isOpen = !brand.isOpen;
        this._brands[brandIndex] = brand;
    }

    handleBrandRemove(event) {
        const brandIndex = event.target.dataset.index;
        this._brands.splice(brandIndex, 1);
    }

    handleStep4FormChange(event) {
        const jobExperienceIndex = event.target.dataset.index;
        const eventType = event.target.type;
        const field = event.target.name;
        const value = (eventType === 'number' ? event.target.value.toString() : event.target.value);
        const jobExperience = this._jobExperience[jobExperienceIndex];
        jobExperience[field] = value;
        this._jobExperience[jobExperienceIndex] = jobExperience;
    }

    handleJobExperienceExpand(event) {
        const jobExperienceIndex = event.target.dataset.index;
        const jobExperience = this._jobExperience[jobExperienceIndex];
        jobExperience.isOpen = !jobExperience.isOpen;
        this._jobExperience[jobExperienceIndex] = jobExperience;
    }

    handleJobExperienceRemove(event) {
        const jobExperienceIndex = event.target.dataset.index;
        this._jobExperience.splice(jobExperienceIndex, 1);
    }

    handleStep5FormChange(event) {
        let value = (event.target.type === 'checkbox') ? event.target.checked : event.target.value;
        const field = event.target.name;
        this._contact[field] = value;
    }

    handleSave() {
        if (this.isStep1) {
            this.step1Save();
        }
        if (this.isStep2) {
            this.step2Save();
        }
        if (this.isStep3) {
            this.step3Save();
        }
        if (this.isStep4) {
            this.step4Save();
        }
        if (this.isStep5) {
            this.step5Save();
        }
    }

    async step1Save() {
        this._isLoading = true;
        try {
            if (this.isFormValid('.step1', 'All fields are required. Please ensure all inputs are valid.')){
                const response = await saveAllData({
                    saveData: {
                        contact: this._contact,
                        brands: [],
                        jobExperience: []
                    }
                });

                if (response.error) {
                    this.showNotification('error', response.error, 'Error:');
                } else if (response.data) {
                    this.nextStep();
                }
            }
        } catch (e) {
            console.log('ERROR_CAUGHT', e.body.message);
        }
        this._isLoading = false;
    }

    async step2Save() {
        this._isLoading = true;
        try {
            if (this.isFormValid('.step2', 'Please ensure all inputs are valid and required fields are filled out.')) {
                const saveParams = {
                    saveData: {
                        contact: this._contact,
                        brands: [],
                        jobExperience: []
                    }
                }

                const profilePics = this._attachments.filter((att) => att.type === 'profilePic');
                if (profilePics.length > 0) {
                    saveParams.saveData.contentVersionId = profilePics[0].contentVersionId;
                }

                const response = await saveAllData(saveParams);

                if (response.error) {
                    this.showNotification('error', response.error, 'Error:');
                } else if (response.data) {
                    this.nextStep();
                }
            }
        } catch (e) {
            console.log('ERROR_CAUGHT', e.body.message);
        }
        this._isLoading = false;
    }

    async step3Save() {
        this._isLoading = true;
        try {
            if (this.isFormValid('.step3', 'Please ensure all inputs are valid and required fields are filled out.')) {
                const response = await saveAllData({
                    saveData: {
                        contact: this._contact,
                        brands: this.cleanBrands(),
                        jobExperience: []
                    }
                });

                if (response.error) {
                    this.showNotification('error', response.error, 'Error:');
                } else if (response.data) {
                    this._brands = response.brands;
                    this.nextStep();
                }
            }
        } catch (e) {
            console.log('ERROR_CAUGHT', e.body.message);
        }
        this._isLoading = false;
    }

    async step4Save() {
        this._isLoading = true;
        try {
            if (this.isFormValid('.step4', 'Please ensure all inputs are valid and required fields are filled out.')) {
                const response = await saveAllData({
                    saveData: {
                        contact: this._contact,
                        brands: [],
                        jobExperience: this.cleanJobExperience()
                    }
                });

                if (response.error) {
                    this.showNotification('error', response.error, 'Error:');
                } else if (response.data) {
                    this._jobExperience = response.jobExperience;
                    this.nextStep();
                }
            }
        } catch (e) {
            console.log('ERROR_CAUGHT', e.body.message);
        }
        this._isLoading = false;
    }

    async step5Save() {
        this._isLoading = true;
        try {
            if (this.isFormValid('.step5', 'Please ensure all inputs are valid and required fields are filled out.')) {
                this._contact = this.formatContactCurrencyFields();

                const response = await saveAllData({
                    saveData: {
                        contact: this._contact,
                        brands: [],
                        jobExperience: []
                    }
                })

                if (response.error) {
                    this.showNotification('error', response.error, 'Error:');
                } else if (response.data) {
                    this.navigateToHomePage();
                }
            }
        } catch (e) {
            console.log('ERROR_CAUGHT', e.body.message);
        }
        this._isLoading = false;
    }

    isFormValid(query, errorMessage) {
        const allValid = [
            ...this.template.querySelectorAll(query),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            this.showNotification('error', errorMessage, 'Validation Error:');
        }
        return allValid;
    }

    formatContactCurrencyFields() {
        const currencyFields = ['Current_Salary__c', 'Minimum_Salary_Requirement__c'];
        const updatedContact = {};
        Object.keys(this._contact).forEach((field) => {
            if (currencyFields.includes(field)) {
                updatedContact[field] = this._contact[field].toString().replace(',', '');
            } else {
                updatedContact[field] = this._contact[field];
            }
        });
        return updatedContact;
    }

    handleResumeUploadFinished(event) {
        this._resumeMessage = '';
        this._attachments = this._attachments.filter((att) => att.type !== 'resume');
        const uploadedFile = event.detail.files[0];
        uploadedFile.type = 'resume';
        this._attachments.push(uploadedFile);
        const message = uploadedFile.name + ' uploaded successfully';
        setTimeout(() => {
            this._resumeMessage = message;
        }, 1000);
    }

    handleProfilePicUploadFinished(event) {
        this._profilePicMessage = '';
        this._attachments = this._attachments.filter((att) => att.type !== 'profilePic');
        const uploadedFile = event.detail.files[0];
        uploadedFile.type = 'profilePic';
        this._attachments.push(uploadedFile);
        const message = uploadedFile.name + ' uploaded successfully';
        setTimeout(() => {
            this._profilePicMessage = message;
        }, 1000);
    }

    addBrand() {
        const brand = {
            key: this._brands.length + 1,
            Consultant_Contact__c: this.recordId
        };
        this._brands.push(brand);
        this.loadHotelBrands();
    }

    addJobExperience() {
        const jobExperience = {
            Consultant__c: this.recordId,
            key: this._jobExperience.length + 1,
        };
        this._jobExperience.push(jobExperience);
        this.loadJobExperience();
    }

    nextStep() {
        let stepInt = parseInt(this.currentStep.split('-')[1], 10);
        stepInt++;
        this.currentStep = 'step-' + stepInt;
    }

    previousStep() {
        let stepInt = parseInt(this.currentStep.split('-')[1], 10);
        stepInt--;
        this.currentStep = 'step-' + stepInt;
    }

    loadStepData() {
        if (this.isStep2) {
            this.loadProfilePicAndResume();
        }
        if (this.isStep3) {
            this.loadHotelBrands();
        }
        if (this.isStep4) {
            this.loadJobExperience();
        }
    }

    loadProfilePicAndResume() {
        const contact = this._contact;
        if (contact.Languages__c) this.selectedLanguages = contact.Languages__c.split(';');
        if (!contact.Delphi_Standard_or_FDC__c) contact.Delphi_Standard_or_FDC__c = '';
    }

    loadHotelBrands() {
        const loadedBrands = [];
        for (let i = 0; i < this._brands.length; i++) {
            const brand = this._brands[i];
            if (brand.Brands__c) brand.selectedOptions = brand.Brands__c.split(';');
            if (!brand.Id && i !== 0) brand.isDeletable = true;
            brand.brandsOptions = this.brandsOptions.data[brand.Family_of_Brands__c];
            brand.isOpen = (!brand.Brands__c && !brand.Other_Brand__c) || brand.key === this._brands.length;
            loadedBrands.push(brand);
        }
        this._brands = loadedBrands;
    }

    loadJobExperience() {
        const loadedJobExperience = [];
        for (let i = 0; i < this._jobExperience.length; i++) {
            const jobExperience = this._jobExperience[i];
            if (!jobExperience.Id && i !== 0) jobExperience.isDeletable = true;
            jobExperience.isOpen = (!jobExperience.Id || !jobExperience.Hotel_Property_Name__c) || jobExperience.key === this._jobExperience.length;
            loadedJobExperience.push(jobExperience);
        }
        this._jobExperience = loadedJobExperience;
    }

    cleanBrands() {
        return this._brands.map((brand) => {
            delete brand.key;
            delete brand.isOpen;
            delete brand.isDeletable;
            delete brand.brandsOptions;
            delete brand.selectedOptions;
            return brand;
        });
    }

    cleanJobExperience() {
        return this._jobExperience.map((job) => {
            delete job.key;
            delete job.isOpen;
            delete job.isDeletable;
            return job;
        });
    }

    showNotification(variant, message, title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

}