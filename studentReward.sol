// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract main is Ownable, AccessControl {

    bytes32 public constant DEPOSITER_ROLE = keccak256("DEPOSITER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");


    // student data
    struct student {
        address id; // address of student acts as his unique id
        uint256 attendance; // a number representing percentage. For example for 70% attendace, attendance = 75;
        string name;
        bool status; // tracks if its a new entry or old.
    }

    address[] private idList;
    address[] private topThree;

    uint256 public studentReward;
    mapping(address => student ) private studentBook ; // a mapping of all students


    event payment_Sent(bool payment_Sent);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _setRoleAdmin(DEPOSITER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        
        grantRole(DEPOSITER_ROLE, owner() );
        grantRole(MANAGER_ROLE, owner() );

    }

    function setReward(uint256 _studentReward) public onlyRole(DEFAULT_ADMIN_ROLE) {
        studentReward = _studentReward;
    }


    function depositeEther() payable public onlyRole(DEPOSITER_ROLE) {
        require( msg.value == 1 ether , "Amount Sent not equal to 1 Ether");
        emit payment_Sent(true); 
    }

    function contractBalance() external view onlyRole(DEPOSITER_ROLE) returns(uint256 _t){
        return( address(this).balance );
    }

    function withdrawtBalance() external onlyRole(DEPOSITER_ROLE) {

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent == true, "Payment to Depositer unsuccessful");
        emit payment_Sent(sent);
    }

    

    function getYourReward() public {
        require ( studentBook[msg.sender].status == true , "You are not a student");
        require ( msg.sender==topThree[0] || msg.sender==topThree[1] || msg.sender==topThree[2], "Not top student" ); 
         
        (bool sent,) = msg.sender.call{value: studentReward}("");
        require(sent == true, "Payment to Student unsuccessful");
        emit payment_Sent(sent);

    }

    function fetchData() public view onlyRole(MANAGER_ROLE) returns(student[] memory _i){

        student[] memory temp = new student[](idList.length);

        for ( uint256 i=0; i< idList.length ; i++ ){
            temp[i].name = studentBook[idList[i]].name;
            temp[i].attendance = studentBook[idList[i]].attendance;
            temp[i].id = studentBook[idList[i]].id;
        }

        return temp;
    }

    function setStudentData(address[] memory _id, string[] memory _name, uint256[] memory _attendance ) public onlyRole(DEFAULT_ADMIN_ROLE) {
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