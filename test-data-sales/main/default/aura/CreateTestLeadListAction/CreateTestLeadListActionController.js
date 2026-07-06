({
  handleFinished: function () {
    // The hosted LWC has generated (or failed to generate) the lead and already
    // raised its own toast. Refresh the list view so a new lead shows up, then
    // dismiss this action panel.
    $A.get('e.force:refreshView').fire();
    $A.get('e.force:closeQuickAction').fire();
  }
})
