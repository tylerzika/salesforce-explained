import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPatient from '@salesforce/apex/TestDataPatientFactory.createPatient';

export default class CreateTestPatient extends LightningElement {
  @api cardTitle = 'Create Test Patient';
  @api autoRun = false;

  isWorking = false;
  hasError = false;
  message;

  @api invoke() {
    this.generate();
  }

  connectedCallback() {
    if (this.autoRun) {
      this.generate();
    }
  }

  handleClick() {
    this.generate();
  }

  async generate() {
    if (this.isWorking) {
      return;
    }
    this.isWorking = true;
    this.hasError = false;
    this.message = null;

    let succeeded = false;
    try {
      const result = await createPatient();
      succeeded = true;
      this.message = `Created ${result.name} — ${result.detail}`;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Test patient created',
          message: this.message,
          variant: 'success'
        })
      );
    } catch (error) {
      this.hasError = true;
      this.message = this.reduceError(error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Could not create patient',
          message: this.message,
          variant: 'error',
          mode: 'sticky'
        })
      );
    } finally {
      this.isWorking = false;
      this.dispatchEvent(new CustomEvent('finished', { detail: { success: succeeded } }));
    }
  }

  get buttonDisabled() {
    return this.isWorking;
  }

  get messageClass() {
    return this.hasError
      ? 'slds-text-color_error slds-p-top_x-small'
      : 'slds-text-color_success slds-p-top_x-small';
  }

  reduceError(error) {
    if (error && error.body && error.body.message) {
      return error.body.message;
    }
    if (error && error.message) {
      return error.message;
    }
    return 'Unexpected error while creating the patient.';
  }
}
