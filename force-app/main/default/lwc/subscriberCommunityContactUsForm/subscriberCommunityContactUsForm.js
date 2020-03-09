import { LightningElement, wire, track } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
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
  contactId;
  caseId;
  userId = USER_ID;
  error;

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
      this.userData.email = data.fields.Email.value;
      this.userData.firstName = data.fields.FirstName.value;
      this.userData.lastName = data.fields.LastName.value;
      this.contactId = data.fields.ContactId.value;
      this.userData.phone = data.fields.Phone.value;
    }
  }

  //Get Publication
  @track publicationValue;

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA", //MASTER RECORD ID
    fieldApiName: CASE_PUBLICATION_FIELD
  })
  publicationPicklistValues;

  //Get Category Picklist
  @track categoryValue = "Feedback"; //Default to Feedback

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA", //MASTER RECORD ID
    fieldApiName: CASE_CATEGORY_FIELD
  })
  categoryPicklistValues;

  constructor() {
    super();
    addEventListener("change", this.handleNameInputChange.bind(this)); //Name Input Event Handler Binding
  }

  contactData = {
    firstName: "",
    lastName: "",
    phoneNumber: "",
    email: ""
  };

  caseData = {
    publication: "",
    category: "",
    description: "",
    message: ""
  };

  userData = {
    firstName: "",
    lastName: "",
    email: "",
    phone: ""
  };

  contactDisplayFieldsList = ["firstName", "lastName"];

  get contactDisplayFields() {
    return this.contactDisplayFieldsList;
  }

  get publicationOptions() {
    return this.publicationPicklistValues.data.values;
  }

  get categoryOptions() {
    return this.categoryPicklistValues.data.values;
  }

  handleNameInputChange(event) {
    this.contactData.firstName = event.target.firstName;
    this.contactData.lastName = event.target.lastName;
  }

  handlePhoneNumberChange(event) {
    this.contactData.phoneNumber = event.target.value;
  }

  handleOnchangeEmailAddress(event) {
    this.contactData.email = event.target.value;
  }

  handlePublicationChange(event) {
    this.caseData.publication = event.target.value;
    this.publicationValue = event.target.value;
  }

  handleCategoryChange(event) {
    this.caseData.category = event.target.value;
    this.categoryValue = event.target.value;
  }

  handleDescriptionChange(event) {
    this.caseData.description = event.target.description;
  }

  submitForm() {
    this.createContact()
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
      });
  }

  createContact() {
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

    return createRecord(contactInput)
      .then(contact => {
        this.contactId = contact.id; //Store the newly created Contact ID
        return Promise.resolve();
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error creating contact",
            message: error,
            variant: "error"
          })
        );
        return Promise.reject();
      });
  }

  createCase() {
    const caseFields = {};

    caseFields[CASE_DESCRIPTION_FIELD.fieldApiName] = this.caseData.description; //Description
    caseFields[CASE_CONTACTID_FIELD.fieldApiName] = this.contactId; //Assign Contact
    caseFields[CASE_PUBLICATION_FIELD.fieldApiName] = this.caseData.publication; //Publication
    caseFields[CASE_CATEGORY_FIELD.fieldApiName] = this.caseData.category; //Category

    const caseInput = {
      apiName: CASE_OBJECT.objectApiName,
      fields: caseFields
    };
    return createRecord(caseInput)
      .then(caseOb => {
        this.caseId = caseOb.id;
        return Promise.resolve();
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error creating Case",
            message: error.body.message,
            variant: "error"
          })
        );
        return Promise.reject();
      });
  }
}