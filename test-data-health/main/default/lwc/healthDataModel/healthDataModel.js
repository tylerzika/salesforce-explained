import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCounts from '@salesforce/apex/TestDataHealthOverview.getCounts';
import createPatient from '@salesforce/apex/TestDataPatientFactory.createPatient';
import createProvider from '@salesforce/apex/TestDataProviderFactory.createProvider';
import createCareProgram from '@salesforce/apex/TestDataCareProgramFactory.createCareProgram';
import enrollPatient from '@salesforce/apex/TestDataEnrolleeFactory.enrollPatient';

// Apex can't be imported dynamically, so the four generators are mapped by node
// key. Adding an object to the diagram = one import + one entry here + one NODES
// entry, which keeps the schema declarative.
const GENERATORS = {
  patient: createPatient,
  provider: createProvider,
  careProgram: createCareProgram,
  enrollee: enrollPatient
};

// Node geometry is fixed in a 1040x560 canvas so the SVG connectors in the
// template can be drawn at known coordinates and stay glued to the boxes. The
// canvas scales as a whole rather than reflowing, which is what keeps it reading
// like a schema instead of a stack of cards.
const NODES = [
  {
    key: 'patient',
    label: 'Patient',
    api: 'Account (Person Account)',
    kind: 'standard',
    x: 380,
    y: 16,
    fields: [
      { name: 'RecordType', type: 'Person Account', accent: true },
      { name: 'FirstName / LastName', type: 'Text' },
      { name: 'PersonBirthdate', type: 'Date' },
      { name: 'PersonEmail', type: 'Email' },
      { name: 'PersonMailingAddress', type: 'Address' }
    ],
    buttonLabel: 'Generate Patient'
  },
  {
    key: 'provider',
    label: 'Healthcare Provider',
    api: 'HealthcareProvider',
    kind: 'standard',
    x: 24,
    y: 316,
    fields: [
      { name: 'Name', type: 'Text', required: true },
      { name: 'ProviderType', type: 'Picklist' },
      { name: 'ProviderClass', type: 'Picklist' },
      { name: 'Status', type: 'Picklist' },
      { name: 'AccountId', type: 'Lookup(Account)', fk: true }
    ],
    buttonLabel: 'Generate Provider'
  },
  {
    key: 'enrollee',
    label: 'Care Program Enrollee',
    api: 'CareProgramEnrollee',
    kind: 'junction',
    x: 380,
    y: 336,
    fields: [
      { name: 'Name', type: 'Text', required: true },
      { name: 'AccountId', type: 'Lookup(Account)', fk: true },
      { name: 'CareProgramId', type: 'Master(CareProgram)', fk: true, required: true },
      { name: 'BenefitCoverageType', type: 'Picklist' },
      { name: 'EnrolleeType', type: 'Picklist' }
    ],
    buttonLabel: 'Enroll a Patient'
  },
  {
    key: 'careProgram',
    label: 'Care Program',
    api: 'CareProgram',
    kind: 'standard',
    x: 736,
    y: 316,
    fields: [
      { name: 'Name', type: 'Text', required: true },
      { name: 'Category', type: 'Picklist' },
      { name: 'Status', type: 'Picklist' },
      { name: 'StartDate / EndDate', type: 'Date' },
      { name: 'SponsorId', type: 'Lookup(Account)', fk: true }
    ],
    buttonLabel: 'Generate Care Program'
  }
];

export default class HealthDataModel extends NavigationMixin(LightningElement) {
  busyKey;
  countsResult;
  counts = {};

  @wire(getCounts)
  wiredCounts(result) {
    this.countsResult = result;
    if (result.data) {
      this.counts = result.data;
    }
  }

  get nodes() {
    return NODES.map((node) => {
      const count = this.counts[node.key];
      return {
        ...node,
        style: `left:${node.x}px; top:${node.y}px;`,
        cssClass: `node node_${node.kind}`,
        headClass: `node-head node-head_${node.kind}`,
        countLabel: count === undefined ? '—' : `${count} record${count === 1 ? '' : 's'}`,
        busy: this.busyKey === node.key,
        fields: node.fields.map((field) => ({
          ...field,
          nameClass: field.fk ? 'fname fname_fk' : field.accent ? 'fname fname_accent' : 'fname'
        }))
      };
    });
  }

  async handleGenerate(event) {
    const key = event.currentTarget.dataset.key;
    if (this.busyKey) {
      return;
    }
    this.busyKey = key;
    try {
      const result = await GENERATORS[key]();
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Record created',
          message: `${result.name} — ${result.detail}`,
          variant: 'success'
        })
      );
      await refreshApex(this.countsResult);
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Could not create the record',
          message: this.reduceError(error),
          variant: 'error',
          mode: 'sticky'
        })
      );
    } finally {
      this.busyKey = undefined;
    }
  }

  reduceError(error) {
    if (error && error.body && error.body.message) {
      return error.body.message;
    }
    if (error && error.message) {
      return error.message;
    }
    return 'Unexpected error while creating the record.';
  }
}
