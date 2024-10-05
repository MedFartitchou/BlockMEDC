pragma solidity ^0.4.23;
import "./MC_Authority.sol";
import "./University.sol";
import "./TranscriptCert.sol";
import "./AcDiploma.sol";
import "./Certs_Profs.sol";
import "./Certs_Students.sol";
import "hardhat/console.sol"; 
import {SharedStructs} from "./Structs.sol";

contract Institution {

    address private owner;       // owner == Institution  
    uint private nb_semesters;  // number of semesters 
    uint private total;        // total number of semesters 
    MC_Authority private Autho; // instance of Sc authority 
    University d;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    mapping(address => SharedStructs.Student) private students;
    mapping(address => SharedStructs.Professor) private Professors;
    mapping(address => SharedStructs.Admin) private Admins;

    // Constructor owner == Dean of Institution 
    constructor(address autho, address univ, address UInstitution, address head) public {
        d = University(univ);
        Autho = MC_Authority(autho);
        require(univ != address(0x0) && UInstitution != address(0x0) && d.CheckInstitution(UInstitution) == true);
        owner = head;
    }

    mapping(address => bool) public authorized;
    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner == msg.sender);
        _;
    }

    // Add an authorized user
    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != address(0));
        authorized[_toAdd] = true;
    }

    // Remove an authorized user
    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != address(0));
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }

    // Add a Professor to the blockchain by authorized owner of Institution
    event RegisteredPr(address from, address to, uint date);
    function AddProfessor(address UInstitution, address Professor, bytes32 id, bytes32 Department) public onlyAuthorized {
        require(UInstitution != address(0x0) && !Professors[Professor].registered);
        Professors[Professor].registered = true;
        Professors[Professor].Professor = Professor;
        Professors[Professor].id = id;
        Professors[Professor].Department = Department;
        emit RegisteredPr(owner, Professor, block.timestamp);
    }

    // Add an Admin to the blockchain by authorized owner of Institution
    event RegisteredAd(address from, address to, uint date);
    function AddAdmin(address UInstitution, address Admin, bytes32 id) public onlyAuthorized {
        require(UInstitution != address(0x0) && !Admins[Admin].registered);
        Admins[Admin].registered = true;
        Admins[Admin].Admin = Admin;
        Admins[Admin].id = id;
        emit RegisteredAd(owner, Admin, block.timestamp);
    }

    // Add a Student to the blockchain by authorized owner of Institution
    event RegisteredSt(address from, address to, uint date);
    function AddStudent(address UInstitution, address student, bytes32 id) public onlyAuthorized {
        require(student != address(0x0) && !students[student].registered && UInstitution != address(0x0));
        students[student].id = id;
        students[student].registered = true;
        students[student].accomplished = 0;
        emit RegisteredSt(owner, student, block.timestamp);
    }

    // Deliberate a student's grade by a professor for a specific subject
    event GradeDeliberated(address student, address professor, uint modifiedNote, string material, uint date);

    function deliberate(
        address studentAddress,
        address professorAddress,
        uint modifiedNote,
        string memory material
    ) public onlyAuthorized {
        require(Professors[professorAddress].registered, "Professor is not registered.");
        require(students[studentAddress].registered, "Student is not registered.");
        require(modifiedNote <= 100, "Modified note must be between 0 and 100.");

        // Update the student's grade for the specific material
        students[studentAddress].trans[keccak256(abi.encodePacked(material))].score = modifiedNote;

        // Emit an event for the grade deliberation
        emit GradeDeliberated(studentAddress, professorAddress, modifiedNote, material, block.timestamp);
    }

    // Additional functionality such as issuing transcript, diploma, etc., from the original code
    event RegisteredTr(address from, address to, uint date);
    event totaled(address from, address to, bytes32 Degre, uint total, uint date);
    event Doc(address from, address to, bytes32 Degre, uint date);
    function issueDocDiploma(address university,address student,bytes32 Degre) public onlyOwner{
    require(student != address(0x0) && university != address(0x0));
    // Degree == Doctorat   
    if(Degre == 0x446f63746f726174000000000000000000000000000000000000000000000000) {
              issueDiploma(student,university);
               
               emit Doc(owner, student, Degre, block.timestamp);

        }
     }

     event ProfessorDoc(address from, address to, bytes32 Degre, uint date);

     function issueProfessorDiploma(address university, address professor, bytes32 Degre) public onlyOwner {
    require(professor != address(0x0) && university != address(0x0), "Invalid professor or university address");
    
    // Assuming Degree == Professor Diplomas (e.g., "Professor" is represented as bytes32)
    if (Degre == 0x50726f666573736f720000000000000000000000000000000000000000000000) { 
        // Issue the diploma (this is similar to your student diploma issuance logic)
        issueDiplomaProf(professor, university);

        // Emit an event for tracking the issuance
        emit ProfessorDoc(owner, professor, Degre, block.timestamp);
    }
    }






    function AddTranscript(address university, address student, bytes32 Degre, bytes32 Semstre, uint note) public onlyAuthorized {
        require(student != address(0x0) && university != address(0x0));

      
       
    if (students[student].registered == true)
    {
         if(students[student].trans[Degre].Semstre == Semstre){
            console.log("transcript already exists");
            }

        else{

        students[student].trans[Degre].Degre = Degre;
        students[student].trans[Degre].Semstre = Semstre;
        students[student].trans[Degre].score = note;
        students[student].trans[Degre].date = block.timestamp;
            if(note >= 10) { 
                students[student].trans[Degre].status = true;
                students[student].accomplished += 1;
                total = total+note;
                issueTranscript(student);
                emit RegisteredTr(owner, student, block.timestamp);
            } 
            else {  students[student].trans[Degre].status = false;
                    issueTranscript(student);
                    emit RegisteredTr(owner, student, block.timestamp);
            }
           // Degree == Deug   
          if(Degre == 0x4465756700000000000000000000000000000000000000000000000000000000)
        {
            nb_semesters = 4;
            
            if (students[student].accomplished == nb_semesters) { 
                students[student].diploms[Degre].Degre = Degre;
                students[student].diploms[Degre].note =  total/nb_semesters;
                
                
                emit totaled(owner, student, Degre, total/nb_semesters, block.timestamp);
            }
            else { console.log("The student has not validated the Diploma of General University Studies (DEUG) ");}    
     
        } 
         // Degree == Licence  
        else if(Degre == 0x4c6963656e636500000000000000000000000000000000000000000000000000)  {
            nb_semesters = 6;
 
            if (students[student].accomplished == nb_semesters) { 
                students[student].diploms[Degre].Degre = Degre;
                students[student].diploms[Degre].note =  total/nb_semesters+students[student].diploms[Degre].note;
                issueDiploma(student,university);
                emit totaled(owner, student, Degre, students[student].diploms[Degre].note, block.timestamp);
            }
            else { console.log("The student has not validated the Diploma (Licence) ");}     
        } 
        // Degree == Master  
        else if(Degre == 0x4d61737465720000000000000000000000000000000000000000000000000000) {
            nb_semesters = 4;
 
               if (students[student].accomplished == nb_semesters) { 
                students[student].diploms[Degre].Degre = Degre;
                students[student].diploms[Degre].note =  total/nb_semesters;
                issueDiploma(student,university);
              
                

                emit totaled(owner, student, Degre, total/nb_semesters, block.timestamp);
            }
            else { console.log("The student has not validated the Diploma (Master) ");} 
        }
        else { 
             console.log("choose the right degree");
        }
            
        }
                    
       }
       else 
       {   
        console.log("student must be registered ");
       }
         
    }

    function issueTranscript(address student) internal {
        require(msg.sender == owner);
        TranscriptCert TrCert = new TranscriptCert(student, owner);
        TrCert.emitt();
    }

    function issueDiploma(address university, address student) internal onlyOwner {
     
        Certs_Students studentDiploma = new Certs_Students(student, university, owner);
        studentDiploma.emitt();
    }

    function issueDiplomaProf(address university, address student) internal onlyOwner {
     
        Certs_Profs professorDiploma = new Certs_Profs(student, university, owner);
        professorDiploma.emitt();
    }

    // Function to validate an academic certification
    function validateCertStudent(address diplomaAddress) public view returns (bool) {
        require(diplomaAddress != address(0x0), "Invalid diploma address");
        Certs_Students studentDiploma  = Certs_Students(diplomaAddress);
        return studentDiploma.isValid();
    }


       function validateCertProf(address diplomaAddress) public view returns (bool) {
        require(diplomaAddress != address(0x0), "Invalid diploma address");
        Certs_Profs professorDiploma  = Certs_Profs(diplomaAddress);
        return professorDiploma.isValid();
    }
}
