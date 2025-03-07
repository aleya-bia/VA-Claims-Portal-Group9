({
    init: function(component, event, helper) {
        helper.loadFaqs(component);
    },

    toggleAnswer: function(component, event, helper) {
        helper.toggleFaq(component, event);
    }
})



// ({
//     myAction : function(component, event, helper) {

//     }
// })