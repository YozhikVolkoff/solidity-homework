pragma solidity ^0.8.7;

contract StudentsGroup {

    struct student {
        string name;
        uint age;
    }

    uint constant GROUPS_NUM = 7;
    student[] students;
    uint[] groups;
    event studentWasAdded(string _name, uint age, uint group);

    function add_student(string memory _name, uint _age) public 
    {
        uint random_group = uint(keccak256(abi.encodePacked(_name))) % GROUPS_NUM;
        students.push(student(_name, _age));
        bool group_exists = false;
        for (uint i = 0; i < GROUPS_NUM; i++)
        {
            if (groups[i] == random_group) 
            {
                group_exists = true;
            }
        }

        if (group_exists == true) {
            groups.push(random_group);
        }

        emit studentWasAdded(_name, _age, random_group);
    }
}
