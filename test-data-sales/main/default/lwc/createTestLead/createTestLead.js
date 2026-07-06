import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createLead from '@salesforce/apex/TestDataLeadFactory.createLead';

export default class CreateTestLead extends LightningElement {
  // Configurable from the Lightning App Builder when placed on a page.
  @api cardTitle = 'Create Test Lead';

  // When true, generate a lead as soon as the component connects. Left false
  // for page placement (a card with a button); set true by the Aura list-view
  // wrapper so the Lead list view keeps its one-click behavior.
  @api autoRun = false;

  isWorking = false;
  hasError = false;
  message;

  // Imperative entry point so a host (e.g. the Aura list-view wrapper) can
  // trigger generation programmatically.
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
      const result = await createLead();
      succeeded = true;
      this.message = `Created ${result.name} — ${result.company}`;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Test lead created',
          message: this.message,
          variant: 'success'
        })
      );
    } catch (error) {
      this.hasError = true;
      this.message = this.reduceError(error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Could not create lead',
          message: this.message,
          variant: 'error',
          mode: 'sticky'
        })
      );
    } finally {
      this.isWorking = false;
      // Notify any host wrapper that the run finished so it can refresh/close.
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
    return 'Unexpected error while creating the lead.';
  }
}
