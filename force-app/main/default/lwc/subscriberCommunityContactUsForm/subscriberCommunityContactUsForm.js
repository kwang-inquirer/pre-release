import { LightningElement, wire, track } from "lwc";
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";

import CONTACT_OBJECT from "@salesforce/schema/Contact";
import CONTACT_FIRSTNAME_FIELD from "@salesforce/schema/Contact.FirstName";
import CONTACT_LASTNAME_FIELD from "@salesforce/schema/Contact.LastName";
import CONTACT_PHONE_FIELD from "@salesforce/schema/Contact.Phone";
import CONTACT_EMAIL_FIELD from "@salesforce/schema/Contact.Email";

import CASE_OBJECT from "@salesforce/schema/Case";
import CASE_CONTACTID_FIELD from "@salesforce/schema/Case.ContactId";
import CASE_DESCRIPTION_FIELD from "@salesforce/schema/Case.Description";
import CASE_PUBLICATION_FIELD from "@salesforce/schema/Case.Publication__c";
import CASE_CATEGORY_FIELD from "@salesforce/schema/Case.Category__c";

import USER_ID from "@salesforce/user/Id";
import USER_FIRSTNAME_FIELD from "@salesforce/schema/User.FirstName";
import USER_LASTNAME_FIELD from "@salesforce/schema/User.LastName";
import USER_EMAIL_FIELD from "@salesforce/schema/User.Email";
import USER_CONTACT_FIELD from "@salesforce/schema/User.ContactId";
import USER_PHONE_FIELD from "@salesforce/schema/User.Phone";

export default class SubscriberCommunityContactUsForm extends LightningElement {
  @track contactId;

  caseId;
  error;
  contactData;
  caseData;

  FORM_READY = 0;
  FORM_WORKING = 1;
  FORM_COMPLETED = 2;
  @track formStatus = this.FORM_WORKING;

  constructor() {
    super();
    this.contactData = {
      firstName: "",
      lastName: "",
      phoneNumber: "",
      email: ""
    };
    this.caseData = {
      publication: "",
      category: "Feedback",
      description: ""
    };
    this.publicationValue = this.caseData.publication;
    this.categoryValue = this.caseData.category;
  }

  @track userFirstName;
  @track userLastName;
  @track userEmail;
  @track userPhone;

  //get Current User
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [
      USER_FIRSTNAME_FIELD,
      USER_LASTNAME_FIELD,
      USER_EMAIL_FIELD,
      USER_CONTACT_FIELD,
      USER_PHONE_FIELD
    ]
  })
  wireuser({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      //Set form prefill
      this.userEmail = data.fields.Email.value;
      this.userFirstName = data.fields.FirstName.value;
      this.userLastName = data.fields.LastName.value;
      this.userPhone = data.fields.Phone.value;

      //Fill User data into contact
      this.contactData.email = this.userEmail;
      this.contactData.firstName = this.userFirstName;
      this.contactData.lastName = this.userLastName;
      this.contactData.phoneNumber = this.userPhone;

      //Fill in contactID Value from User
      this.contactId = data.fields.ContactId.value;
    }
    this.formIsReady();
  }

  //Get Publication
  @track publicationValue;

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA", //MASTER RECORD ID
    fieldApiName: CASE_PUBLICATION_FIELD
  })
  publicationPicklistValues;

  //Get Category Picklist
  @track categoryValue; //Default to Feedback

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA", //MASTER RECORD ID
    fieldApiName: CASE_CATEGORY_FIELD
  })
  categoryPicklistValues;

  contactDisplayFieldsList = ["firstName", "lastName"];

  get userFirstNameValue() {
    return this.userFirstName;
  }
  get userLastNameValue() {
    return this.userLastName;
  }
  get userEmailValue() {
    return this.userEmail;
  }
  get userPhoneValue() {
    return this.userPhone;
  }
  get contactDisplayFields() {
    return this.contactDisplayFieldsList;
  }

  get publicationOptions() {
    return this.publicationPicklistValues.data.values;
  }

  get categoryOptions() {
    return this.categoryPicklistValues.data.values;
  }

  get getContactId() {
    return this.contactId;
  }

  /** FORM STATUS HANDLER */
  get isFormReady() {
    return this.formStatus === this.FORM_READY;
  }

  get isFormWorking() {
    return this.formStatus === this.FORM_WORKING;
  }

  get isFormCompleted() {
    return this.formStatus === this.FORM_COMPLETED;
  }

  formIsReady() {
    this.formStatus = this.FORM_READY;
  }

  formIsWorking() {
    this.formStatus = this.FORM_WORKING;
  }

  formIsCompleted() {
    this.formStatus = this.FORM_COMPLETED;
  }

  /** EVENT HANDLERS */
  handleNameInputChange(event) {
    this.contactData.firstName = event.detail.firstName || ""; //stop empty string being undefined
    this.contactData.lastName = event.detail.lastName || ""; //Stop empty string being undefined
  }

  handlePhoneNumberChange(event) {
    this.contactData.phoneNumber = event.detail.value;
  }

  handleOnchangeEmailAddress(event) {
    this.contactData.email = event.detail.value;
  }

  handlePublicationChange(event) {
    this.caseData.publication = event.detail.value;
    this.publicationValue = event.detail.value;
  }

  handleCategoryChange(event) {
    this.caseData.category = event.detail.value;
    this.categoryValue = event.detail.value;
  }

  handleDescriptionChange(event) {
    this.caseData.description = event.detail.value;
  }

  //** FORM SUBMIT HANDLER */
  submitForm() {
    if (!this.contactId) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Unable to submit form",
          message: "You must be a subscriber to submit", //A community member will have a contact. Without contact, no form will be submit
          variant: "error"
        })
      );
      return;
    }
    this.formIsWorking();

    const allValid = [
      ...this.template.querySelectorAll("lightning-input")
    ].reduce((validSoFar, inputFields) => {
      inputFields.reportValidity();
      return validSoFar && inputFields.checkValidity();
    }, true); //This should validate all inputs

    if (!allValid) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Something Wrong",
          message: "Please check your input then try again",
          variant: "error"
        })
      );
      this.formIsReady();
      return;
    }

    return this.updateContact() //Should Update Contact here?
      .then(() => {
        return this.createCase();
      })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Case ID: " + this.caseId,
            variant: "success"
          })
        );
        this.formIsCompleted();
      })
      .catch(error => {
        this.dispatchEvent(error);
        this.formIsReady();
      });
  }

  updateContact() {
    const contactFields = {};

    contactFields[
      CONTACT_FIRSTNAME_FIELD.fieldApiName
    ] = this.contactData.firstName; //First Name
    contactFields[
      CONTACT_LASTNAME_FIELD.fieldApiName
    ] = this.contactData.lastName; //Last Name
    contactFields[
      CONTACT_PHONE_FIELD.fieldApiName
    ] = this.contactData.phoneNumber; //Phone Number
    contactFields[CONTACT_EMAIL_FIELD.fieldApiName] = this.contactData.email; //Email

    const contactInput = {
      apiName: CONTACT_OBJECT.objectApiName,
      fields: contactFields
    };

    return updateRecord(contactInput).catch(error => {
      return Promise.reject(
        new ShowToastEvent({
          title: "Error updating contact",
          message: error,
          variant: "error"
        })
      );
    });
  }

  createCase() {
    const caseFields = {};

    caseFields[CASE_CONTACTID_FIELD.fieldApiName] = this.contactId; //Assign Contact
    caseFields[CASE_DESCRIPTION_FIELD.fieldApiName] = this.caseData.description; //Description
    caseFields[CASE_PUBLICATION_FIELD.fieldApiName] = this.caseData.publication; //Publication
    caseFields[CASE_CATEGORY_FIELD.fieldApiName] = this.caseData.category; //Category

    const caseInput = {
      apiName: CASE_OBJECT.objectApiName,
      fields: caseFields
    };
    return createRecord(caseInput)
      .then(caseRecord => {
        this.caseId = caseRecord.id;
        return Promise.resolve();
      })
      .catch(error => {
        return Promise.reject(
          new ShowToastEvent({
            title: "Error creating Case",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }
}
