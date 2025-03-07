({
    loadFaqs: function(component) {
        // Define the FAQ list
        let faqs = [
            { question: "  How do I submit a claim?", 
                answer: "You can submit a claim by clicking 'Submit a Claim' or you can contact our support.", 
                expanded: false },
            { question: "  What is the status of my appeal?", 
                answer: "You can check your appeal status in the Claims Data section.", 
                expanded: false },
            { question: "  How long does it take to process a claim?", 
                answer: "The time for processing depends on the complexity of your case, but typically it takes 30-90 days.", 
                expanded: false },
            { question: "  Can I upload additional documents?", 
                answer: "Yes, you can upload documents under your Claim or Appeal Details page in the Claims Data section.", 
                expanded: false },
            { question: "  What if I have more questions?", 
                answer: "You can call us at 877-222-8387. We are here Monday through Friday, 8:00 a.m. to 8:00 p.m. ET.", 
                expanded: false }
        ];

        // Set the attribute in the component
        component.set("v.faqList", faqs);
    },

    toggleFaq: function(component, event) {
        let index = event.currentTarget.dataset.index;
        let faqs = component.get("v.faqList");

        // Toggle the expanded state of the selected FAQ
        faqs[index].expanded = !faqs[index].expanded;

        // Update the component state
        component.set("v.faqList", faqs);
    }
});


// ({
//     helperMethod : function() {

//     }
// })