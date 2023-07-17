//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.5.0<=0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract voting_system{
    address public admin;
    uint deadline;
  
    struct candidatesforelection
    {
        string name;
        address candidate;
        uint votes;
        
    }
    
    uint public numcandidates=1;
    mapping(uint=>candidatesforelection) public candi;
    mapping(address=>bool) public alreadyvoted;
    
    modifier onlyadmin(){
        require(admin==msg.sender,"This function requires only admin");_;
    }
    constructor(uint _deadline)
    {
        admin=msg.sender;
        deadline=block.timestamp+_deadline;
    }

    function contestingcandidates(string memory _name,address _candidate)public onlyadmin
    {
        require(admin!=_candidate,"Admin cannot be a candidate");
        candidatesforelection storage newcandidate=candi[numcandidates];
        numcandidates++;
        newcandidate.name=_name;
        newcandidate.candidate=_candidate;
        newcandidate.votes=0;
    }
    function castevote(uint num) public 
    {
        require(block.timestamp<deadline,"Deadline to cast the vote has been passed");
        address user=msg.sender;
        require(alreadyvoted[user]==false,"You have already voted");
        candidatesforelection storage thisrequest=candi[num];
        thisrequest.votes++;
        alreadyvoted[user]=true;
    }
    function winner() public view returns (string memory)
    {
        uint maxi=0;
        uint winnerno=0;
        string memory win="";
        for(uint i=1;i<=2;i++)
        {
            candidatesforelection storage thisrequest=candi[i];
            if(thisrequest.votes>maxi)
            {
                maxi=thisrequest.votes;
                winnerno=i;
                 win=thisrequest.name;
            }
        }
        return win;
    }

}