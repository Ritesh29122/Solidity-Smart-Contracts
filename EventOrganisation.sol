//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.5.0 <=0.9.0;
contract EventOrganisation
{
    struct Event
    {
        address organiser;
        string name;
        uint date;
        uint ticketcount;
        uint ticketremain;
        uint price;
    }
    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextid;
    function createEvent(string memory name,uint price,uint date,uint ticketcount) external 
    {
        require(date>block.timestamp,"You can only organize event for future date");
        require(ticketcount>0,"You should buy some tickets");
        events[nextid]=Event(msg.sender,name,date,ticketcount,ticketcount,price);
        nextid++;
    } 
    function buyticket(uint id,uint quantity) external payable
    {
        require(events[id].date!=0,"This event does not exist");
        require(block.timestamp<events[id].date,"Event has already occured ");
        Event storage _event=events[id];
        require(msg.value==(_event.price* quantity),"Ether is not enough");
        require(_event.ticketremain>=quantity,"There are not enough token remaining");
        _event.ticketremain-=quantity;
        tickets[msg.sender][id]+=quantity;
    }
    function transferticket(uint eventid,uint quantity,address receiver) external payable
    {
        require(block.timestamp<events[eventid].date,"Event has already occured");
        require(tickets[msg.sender][eventid]>=quantity,"You do not have enough tickets to send");
        tickets[msg.sender][eventid]-=quantity;
        tickets[receiver][eventid]+=quantity;
    }
}