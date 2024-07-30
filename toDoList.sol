pragma solidity ^0.8.0;

contract ToDolist{
    uint public _idUser;
    address public ownerOfContract;

    address[] public creators;
    string[] public message;
    uint256[] public messageId;

    struct ToDoListApp{
        address account;
        uint256 userId;
        string message;
        bool completed;
    }
    event ToDoListevent(
        address indexed account,
        uint256 indexed userId,
        string message,
        bool completed
    );

    mapping(address => ToDoListApp) public toDoListApps;

    constructor(){
        ownerOfContract = msg.sender;
    }
    function inc() internal{
        _idUser++;
    }
    function createList(string calldata _message) external {
        inc();
        uint256 idNumber = _idUser;
        ToDoListApp storage toDo = toDoListApps[msg.sender];
        toDo.account = msg.sender;
        toDo.message = _message;
        toDo.completed = false;
        toDo.userId = idNumber;

        creators.push(msg.sender);
        message.push(_message);
        messageId.push(idNumber);
        emit ToDoListevent(msg.sender, toDo.userId, _message, toDo.completed);
    }

        

    function getCreatorData (address _address) public view returns (address, string memory,uint256, bool) {
        ToDoListApp memory singleUserData = toDoListApps[_address];
           return (
                singleUserData.account,
                singleUserData.message,
                singleUserData.userId,
                singleUserData.completed
            );
    }

    function getAddress() external view returns(address[] memory) {
        return creators;
    }
    function getMessage() external view returns(string[] memory){
        return message;
    }

    function toggle (address _creator) public {
        ToDoListApp storage singleUserData = toDoListApps[_creator];
        singleUserData.completed = !singleUserData.completed;
    }
    
}