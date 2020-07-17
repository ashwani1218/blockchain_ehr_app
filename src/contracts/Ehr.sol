pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Ehr is AccessControl{

    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR");
    address root = msg.sender;

    constructor () public {
        _setupRole(DEFAULT_ADMIN_ROLE, root);
        _setRoleAdmin(DOCTOR_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PATIENT_ROLE, DOCTOR_ROLE);
    }

    modifier onlyAdmin() {
      require(isAdmin(msg.sender), "Restricted to admins.");
      _;
    }

    modifier onlyDoctor() {
      require(isDoctor(msg.sender), "Restricted to doctors.");
      _;
    }

    modifier onlyDoctorPatient(){
    
      require(isUser(msg.sender), "Restricted to registered users");
     
      _;
    }
    // To allow doctors and the patient who owns the record access their data
    function isUser(address account) public virtual view returns (bool) {
      if(hasRole(DOCTOR_ROLE, account)){
        return true;
      } else if(hasRole(PATIENT_ROLE, account)){
        return true;
      } else if(hasRole(DEFAULT_ADMIN_ROLE, account)) {
        return true;
      } else {
        return false;
      }
    }

    function isAdmin(address account) public virtual view returns (bool) {
      return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function isDoctor(address account) public virtual view returns (bool) {
      return hasRole(DOCTOR_ROLE, account);
    }

    function isPatient(address account) public virtual view returns (bool) {
      return hasRole(PATIENT_ROLE, account);
    }

    function addDoctorRole(address account) public virtual onlyAdmin {
      grantRole(DOCTOR_ROLE, account);
    }

    function addPatientRole(address account) public virtual onlyDoctor {
      grantRole(PATIENT_ROLE, account);
    }

    struct PatientDetails {
        address addr;
        string name;
        string email;
        string password;
        string patientHash;
    }

    struct DoctorDetails {
        address addr;
        string name;
        string email;
        string password;
    }

    mapping (address => PatientDetails) patients;
    mapping (address => DoctorDetails) doctors;

    function newPatient(
        address _address,
        string calldata _name,
        string calldata _email,
        string calldata _password,
        string calldata _patientHash) external onlyDoctor {
        patients[_address] = PatientDetails(_address,
                                            _name,
                                            _email,
                                            _password,
                                            _patientHash); 
        addPatientRole(_address);
    }

    function newDoctor(
        address _address,
        string calldata _name,
        string calldata _email,
        string calldata _password) external onlyAdmin {
            doctors[_address] = DoctorDetails(_address,
                                            _name,
                                            _email,
                                            _password);
        addDoctorRole(_address);
    }
    

    function getPatient(address _address) public view onlyDoctorPatient returns (address, string memory, string memory, string memory, string memory){
      if(patients[_address].addr == msg.sender || isDoctor(msg.sender)){
        return (patients[_address].addr,
                patients[_address].name,
                patients[_address].email,
                patients[_address].password,
                patients[_address].patientHash);
       } 
      revert('Patient does not exist or you do not have access to this record');
       

    }

    function getDoctor(address _address) public view onlyAdmin returns(address, string memory, string memory, string memory){
        if(doctors[_address].addr == _address){
          return (doctors[_address].addr,
                doctors[_address].name,
                doctors[_address].email,
                doctors[_address].password);
        }
        revert('Doctor does not exist');
            
    }

    function updatePatient(address _address, 
                          string memory _name,
                          string memory _email,
                          string memory _password,
                          string memory _patientHash) public onlyDoctor {
      patients[_address].name = _name;
      patients[_address].email = _email;
      patients[_address].password = _password;
      patients[_address].patientHash = _patientHash;
    }

    function destroyPatient(address _address) public onlyDoctor {
        delete patients[_address];
    }



}