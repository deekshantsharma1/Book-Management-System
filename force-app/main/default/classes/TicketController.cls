public with sharing class TicketController {

    @AuraEnabled
    public static Id createTicket(String subject, String description, 
                                   String priority, Id contactId) {
        try {
            Ticket__c ticket = new Ticket__c(
                Subject__c = subject,
                Description__c = description,
                Priority__c = priority,
                Status__c = 'New',
                Contact__c = contactId
            );
            insert ticket;
            return ticket.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Ticket__c> getTickets() {
        return [
            SELECT Id, Subject__c, Priority__c, Status__c, CreatedDate
            FROM Ticket__c
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void updateTicketStatus(Id ticketId, String status) {
        Ticket__c ticket = [SELECT Id, Status__c FROM Ticket__c WHERE Id = :ticketId LIMIT 1];
        ticket.Status__c = status;
        update ticket;
    }
}
