pragma solidity ^0.8.0;
contract Ballot{

    struct Voters{
        bool voted;
        uint access;
        uint vote;
    }

    struct Proposal {
    bytes32 name;
    uint voteCount;
    }
    Proposal[] public proposals;

    mapping(address => Voters) public voters;
    address public chairperson;

    constructor(bytes32[] memory proposalNames){
        chairperson = msg.sender;
        voters[chairperson].access = 1;

        for (uint i=0; i<proposalNames.length; i++) 
        {
            proposals.push(Proposal({
                name : proposalNames[i],
                voteCount : 0
            }));
        }
    }
    function giveRightToVote(address voter)  public {
        require(msg.sender == chairperson, 'Only the chairperson give access to vote.');
        require(!voters[voter].voted, 'the voter is already voted.');
        require(voters[voter].vote == 0);
        voters[voter].vote = 1;
    }
    function vote(uint proposal) public {
        Voters storage sender = voters[msg.sender];
        require(sender.vote != 0,'has no right to vote.');
        require(!sender.voted, 'Alredy Voted');
        sender.voted =true;
        sender.vote = proposal;

        proposals[proposal].voteCount = proposals[proposal].voteCount + sender.vote;
    }
    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for(uint i =0; i < proposals.length;i++){
            if(proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    function winningName() public view returns(bytes32 winningName_) {
        winningName_ = proposals[winningProposal()].name;
    }
}