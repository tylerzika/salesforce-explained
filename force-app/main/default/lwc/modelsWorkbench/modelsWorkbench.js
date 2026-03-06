import { LightningElement } from 'lwc';

export default class ModelsWorkbench extends LightningElement {
  cards = [];
  cardSequence = 1;

  connectedCallback() {
    if (!this.cards.length) {
      this.addCard();
    }
  }

  get hasCards() {
    return this.cards.length > 0;
  }

  get cardCountLabel() {
    return `${this.cards.length} active ${this.cards.length === 1 ? 'card' : 'cards'}`;
  }

  handleAddCard() {
    this.addCard();
  }

  handleDeleteCard(event) {
    this.cards = this.cards.filter((card) => card.id !== event.detail.cardId);
  }

  addCard() {
    this.cards = [
      ...this.cards,
      {
        id: `card-${this.cardSequence}`,
        title: `Card ${this.cardSequence}`
      }
    ];
    this.cardSequence += 1;
  }
}
