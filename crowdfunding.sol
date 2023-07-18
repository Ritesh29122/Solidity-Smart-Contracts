//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
contract crowdfunding{
    mapping(address =>uint) public contributors;
    address public manager;
    uint public minimumcontribution;
    uint public target;
    uint public deadline;
    uint public raisedamount;
    uint public noofcontributors;
    
    struct Request{
            string description;
            address payable recipient;
            uint value;
            bool completed;
            uint noofvoters;
            uint totalamountforcause;
            mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numrequests;

    constructor(uint _target,uint _deadline)
    {
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumcontribution=100 wei;
        manager=msg.sender;
    }
    function sendEth() public payable {
        require(deadline>block.timestamp,"deadline has passed");
        require(minimumcontribution<=msg.value,"Your contribution is below the set limit");

        if(contributors[msg.sender]==0)
        {
            noofcontributors++;
        }
        contributors[msg.sender]=contributors[msg.sender]+msg.value;
        raisedamount=raisedamount+msg.value;
    }
    function getcontractbalance() public view returns(uint)
    {
        return address(this).balance;
    }
    function refund() public payable 
    {
        require(block.timestamp>deadline && raisedamount<target,"Deadline is reached and target is not met");
        require(contributors[msg.sender]>0,"You have not contributed");
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlymanager()
    {
        require(msg.sender==manager,"Only manager can call this function");_;
    }
    function createrequest(string memory _description,address payable _recipient,uint _value)public onlymanager
    {
        Request storage newRequest= requests[numrequests];
        numrequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        //newRequest.totalamountforcause+=_value;
        newRequest.completed=false;
        newRequest.noofvoters=0;

    }
    function voterequest(uint _requestno) public
    {
        require(contributors[msg.sender]>0,"You have not contributed till now");
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.voters[msg.sender]==false,"You have already voted");
        thisrequest.voters[msg.sender]=true;
        thisrequest.totalamountforcause+=thisrequest.value;
        thisrequest.noofvoters++;
    }
    function makepayment(uint _requestno) public onlymanager
    {
        require(raisedamount>=target,"You have not achieved target amount");
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.completed==false,"The request has been completed");
        require(thisrequest.noofvoters>=noofcontributors,"Approval is less than 50 percent");
        address payable user=payable(msg.sender);
        user.transfer(thisrequest.totalamountforcause);
        thisrequest.completed=true;
    }
} 