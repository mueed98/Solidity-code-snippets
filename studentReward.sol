// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract main is Ownable {

    address public admin;
    address public depositer;

    // student data
    struct student {
        address id; // address of student acts as his unique id
        uint256 attendance; // a number representing percentage. For example for 70% attendace, attendance = 75;
        string name;
        bool status; // tracks if its a new entry or old.
    }

    address[] private idList;
    address[] private topThree;

    mapping(address => student ) private studentBook ; // a mapping of all students

    mapping(address => bool ) private managerBook ; // a mapping of all managers

    modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }

    modifier onlyDepositor {
      require(msg.sender == depositer, "Not a depositer");
      _;
    }

    modifier onlyManager {
        require(managerBook[msg.sender] == true, "Not an Account Manager");
        _;
    }

    event payment_Sent(bool payment_Sent);

    constructor() {
        admin = msg.sender;
        depositer = msg.sender;
        managerBook[msg.sender] = true;
        console.log("Contract Created with Owner as : ", admin);

    }

    

    function setAdmin(address _admin) public onlyOwner{
        admin = _admin;
        console.log("New Admin is : ", admin);    
    }

    function setDepositor(address _depositer) public onlyAdmin{
        depositer = _depositer;
        console.log("New depositer is : ", depositer);    
    }

    // if status = false, then given addresses are not managers. if status = true, then are managers. By default its false for any address
    function setManagerStatus(address[] memory _manager, bool _status) public onlyAdmin{
        for( uint256 i=0; i<_manager.length;i++){
            managerBook[_manager[i]] = _status;
        }   
    }

    function depositeEther() payable public onlyDepositor {
        require( msg.value == 1 ether , "Amount Sent not equal to 1 Ether");
        emit payment_Sent(true); 
    }

    function contractBalance() external view onlyDepositor returns(uint256 _t){
        return( address(this).balance );
    }

    function withdrawtBalance() external onlyDepositor{

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent == true, "Payment to Depositer unsuccessful");
        emit payment_Sent(sent);
    }

    

    function getYourReward() public {
        address _t = msg.sender;
        require ( studentBook[_t].status == true , "You are not a student");
        require ( _t==topThree[0] || _t==topThree[1] || _t==topThree[2], "Not top student" ); 
         
        uint256 fee = 0.3 ether; // each gets 0.3 ether
        (bool sent,) = _t.call{value: fee}("");
        require(sent == true, "Payment to Student unsuccessful");
        emit payment_Sent(sent);

    }

    function fetchData() public view onlyManager returns(student[] memory _i){

        student[] memory temp = new student[](idList.length);

        for ( uint256 i=0; i< idList.length ; i++ ){
            temp[i].name = studentBook[idList[i]].name;
            temp[i].attendance = studentBook[idList[i]].attendance;
            temp[i].id = studentBook[idList[i]].id;
        }

        return temp;
    }

    function setStudentData(address[] memory _id, string[] memory _name, uint256[] memory _attendance ) public onlyAdmin {
        require( (_id.length == _name.length) && ( _name.length == _attendance.length), "Length of arrays not same" );

        for( uint256 i=0; i<_id.length;i++){
            if ( studentBook[_id[i]].status == false )
                idList.push( _id[i] );

            studentBook[_id[i]].id = _id[i];
            studentBook[_id[i]].name = _name[i];
            studentBook[_id[i]].attendance = _attendance[i];
            studentBook[_id[i]].status = true;
            console.log(studentBook[_id[i]].id);

            if ( topThree.length==3 )
                if ( studentBook[_id[i]].attendance > studentBook[ topThree[2] ].attendance ){
                    topThree[2] = _id[i];
                    if ( studentBook[_id[i]].attendance > studentBook[ topThree[1] ].attendance ) {
                        topThree[2] = topThree[1] ;
                        topThree[1] = _id[i];
                        if ( studentBook[_id[i]].attendance > studentBook[ topThree[0] ].attendance ){
                            topThree[1] = topThree[0] ;
                            topThree[0] = _id[i];
                        }    
                    } 
                }
            else
                topThree.push(_id[i]);

        }
    }

    // students fetches his data
    function getYourData( ) public view returns(student memory _t){
        require ( studentBook[msg.sender].status == true , "You are not a student");
        return studentBook[msg.sender]; 
    }


}